/*
 * MovieCreator.java
 * 
 * Copyright (c) 2012 Hendrik Holtmann
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

package com.mmslides.MovieCreator;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.channels.FileChannel;
import java.nio.channels.FileLock;
import java.util.Properties;

import org.im4java.process.ProcessStarter;

public class MovieCreator
{
  private static File f;
  private static FileChannel channel;
  private static FileLock lock;

  public static void main(String[] args) {
      try {
          f = new File("moviecreator.lock");
          // Check if the lock exist
          if (f.exists()) {
              // if exist try to delete it
              f.delete();
          }
          // Try to get the lock
          channel = new RandomAccessFile(f, "rw").getChannel();
          lock = channel.tryLock();
          if(lock == null)
          {
              // File is lock by other application
              channel.close();
              throw new RuntimeException("Only ONE instance of MovieCreator can run.");
          }
          // Add shutdown hook to release lock when application shutdown
          ShutdownHook shutdownHook = new ShutdownHook();
          Runtime.getRuntime().addShutdownHook(shutdownHook);

          String fileName = null;
          try
					{
						File jarFile = new File(MovieCreator.class.getProtectionDomain().getCodeSource().getLocation().toURI());
						String appdir = jarFile.getParentFile().getAbsolutePath();
						if (new File(appdir + File.separator + "MovieCreator.config").exists())
						{
							fileName = appdir + File.separator + "MovieCreator.config";
						}
					}
					catch (Exception e)
					{
					}
					if (fileName == null)
					{
						if (new File("/etc/MovieCreator.config").exists())
						{
							fileName = "/etc/MovieCreator.config";
						}
					}
          Properties prop = new Properties();
					if (fileName == null)
					{
						prop.setProperty("server.dir", "http://127.0.0.1/mmslideserver/moviecreator");
						prop.setProperty("moviedownloader", "http://127.0.0.1/mmslideserver/moviedownloader.php");
						prop.setProperty("queue.dir", "/opt/mmslide/moviequeue");
						prop.setProperty("movie.dir", "/opt/mmslide/movies");
						prop.setProperty("im.path", "/usr/local/ImageMagick/bin");
						prop.setProperty("ffmpeg.app", "/usr/local/bin/ffmpeg");
						prop.setProperty("mail.from", "mmslides@example.com");
						prop.setProperty("mail.smtp.host", "localhost");
					}
					else
					{
	          InputStream is;
	      		try
	      		{
	      			is = new FileInputStream(fileName);
	      	    prop.load(is);
	      		}
	      		catch (FileNotFoundException e)
	      		{
	      			// TODO Auto-generated catch block
	      			e.printStackTrace();
	      		}
	      		catch (IOException e)
	      		{
	      			// TODO Auto-generated catch block
	      			e.printStackTrace();
	      		}
					}
      		
      		ProcessStarter.setGlobalSearchPath(prop.getProperty("im.path"));

      		Runnable runnable = new MovieCreatorThread(prop);
      		Thread thread = new Thread(runnable);
      		thread.start();
      }
      catch(IOException e)
      {
          throw new RuntimeException("Could not start process.", e);
      }

  }

  public static void unlockFile() {
      // release and delete file lock
      try {
          if(lock != null) {
              lock.release();
              channel.close();
              f.delete();
          }
      } catch(IOException e) {
          e.printStackTrace();
      }
  }

  static class ShutdownHook extends Thread {

      public void run() {
          unlockFile();
      }
  }
}
