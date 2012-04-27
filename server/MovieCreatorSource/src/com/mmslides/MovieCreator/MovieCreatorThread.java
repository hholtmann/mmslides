/*
 * MovieCreatorThread.java
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

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Properties;
import java.util.UUID;


import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.apache.log4j.Logger;
import org.im4java.core.CompositeCmd;
import org.im4java.core.ConvertCmd;
import org.im4java.core.IM4JavaException;
import org.im4java.core.IMOperation;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

public class MovieCreatorThread implements Runnable
{
	private static Logger LOG = Logger.getLogger(MovieCreatorThread.class); 
	
	private Properties props;
	private double fps;
	private Hashtable<String, MovieData> createdMovies;
	private long timelimit = 1000*60*60*24; // 4 hours
	private static int movieID = 1;
	
	public MovieCreatorThread(Properties properties)
	{
		super();
		fps = 30.0;
		props = properties;
		createdMovies = new Hashtable<String, MovieData>();
		emptyMovieDir();
	}
	
	private void purgeCreatedMovies()
	{
    for (Enumeration<String> e = createdMovies.keys() ; e.hasMoreElements() ;) 
    {
    	String key = e.nextElement();
    	MovieData data = createdMovies.get(key);
    	if (System.currentTimeMillis() - data.getTimestamp().getTime() > timelimit)
    	{
    		// delete movie file
    		File f = new File(createdMovies.get(key).getFilename());
    		if (f.exists())
    		{
    			String parent = f.getParent();
    			f.delete();
    			f = new File(parent);
    			f.delete();
    		}
    		// delete id file
    		File idfile = new File(props.getProperty("movie.dir") + File.separator + data.getId());
    		if (idfile.exists())
    		{
    			idfile.delete();
    		}
				LOG.debug("purge " + createdMovies.get(key).getFilename());
    		createdMovies.remove(key);
    	}
	  }
	}
	
	private void emptyMovieDir()
	{
		File dir = new File(props.getProperty("movie.dir"));

		String[] children = dir.list();
		if (children != null && children.length != 0) 
		{
			for (int i=0; i<children.length; i++) 
			{
				LOG.debug("delete " + dir.getAbsolutePath() + File.separator + children[i]);
				recursiveDelete(new File(dir.getAbsolutePath() + File.separator + children[i]));    	
			}
		}
	}

  protected String fileToString(String fileName) throws IOException 
  {
    StringBuffer sb = new StringBuffer();
    BufferedReader in = new BufferedReader(new FileReader(fileName));
    String s;
    while((s = in.readLine()) != null) {
      sb.append(s);
      sb.append("\n");
    }
    in.close();
    return sb.toString();
  }
	
	protected String getNextQueueFile()
	{
		File dir = new File(this.props.getProperty("queue.dir"));

		String[] children = dir.list();
		if (children == null || children.length == 0) 
		{
			return null;
		} 
		else 
		{
			return dir.getAbsolutePath() + File.separator + children[0];
		}
	}
	
	public JSONObject objectForKey(JSONObject obj, String key)
	{
		try
		{
			return (JSONObject)obj.get(key);
		}
		catch (NullPointerException e)
		{
			LOG.debug(e.getMessage());
			return null;
		}
	}
	
	public JSONArray arrayForKey(JSONObject obj, String key)
	{
		try
		{
			return (JSONArray)obj.get(key);
		}
		catch (NullPointerException e)
		{
			LOG.debug(e.getMessage());
			return null;
		}
	}
	
	public void kenBurns(File src, File dst, double x, double y, double w, double h, double w_tot, double h_tot)
	{
		ConvertCmd convert = new ConvertCmd();
  	IMOperation op = new IMOperation();
  	op.addImage(src.getAbsolutePath());
		op.crop((int)Math.round(w), (int)Math.round(h), (int)Math.round(x), (int)Math.round(y));
		op.resize((int)Math.round(w_tot), (int)Math.round(h_tot));
  	op.addImage(dst.getAbsolutePath());
		try
		{
			convert.run(op);
		}
		catch (IM4JavaException e)
		{
			LOG.debug(e.getMessage());
		}
		catch (IOException e)
		{
			LOG.debug(e.getMessage());
		}
		catch (InterruptedException e)
		{
			LOG.debug(e.getMessage());
		}
	}
	
	public void addLabel(String imagefile, String caption, int width)
	{
		ConvertCmd convert = new ConvertCmd();
  	IMOperation op = new IMOperation();
		op.background("#000a");
  	op.fill("white");
  	op.gravity("center");
  	op.size(width);
  	op.font("Helvetica-Bold");
  	op.pointsize(18);
  	op.addImage("caption:\\n" + caption + "\\n");
		op.addImage(imagefile);
		op.p_swap();
		op.gravity("south");
		op.composite();
		op.addImage(imagefile);
		try
		{
			convert.run(op);
		}
		catch (IM4JavaException e)
		{
			LOG.debug(e.getMessage());
		}
		catch (IOException e)
		{
			LOG.debug(e.getMessage());
		}
		catch (InterruptedException e)
		{
			LOG.debug(e.getMessage());
		}
	}

//	public void slideleft(File tempdir, String src, String dst, String output, int width, int height, int pixels)
	public void slideleft(File tempdir, Slide previousSlide, Slide slide, long transitions, int width, int height)
	{
		String lastframe = tempdir.getAbsolutePath() + File.separator + String.format("video_%1$d.jpg", previousSlide.getEndFrame());
		String black = tempdir.getAbsolutePath() + File.separator + "blackimage.jpg";
		String temp = tempdir.getAbsolutePath() + File.separator + "tempimage.jpg";
  	CompositeCmd composite = new CompositeCmd();
  	double counter = 0;
		for (long i = slide.getStartFrame(); i < slide.getStartFrame()+transitions; i++)
		{
	  	IMOperation op = new IMOperation();
			op.geometry(width, height, width-new Double((counter/transitions)*width).intValue(), 0);
	  	op.addImage();
			op.addImage();
	 		op.addImage();
	  	IMOperation op2 = new IMOperation();
			op2.geometry(width, height, -new Double((counter/transitions)*width).intValue(), 0);
	  	op2.addImage();
			op2.addImage();
	 		op2.addImage();
			try
			{
				composite.run(op, tempdir.getAbsolutePath() + File.separator + String.format("video_%1$d.jpg", i), black, temp);
				composite.run(op2, lastframe, temp, tempdir.getAbsolutePath() + File.separator + String.format("video_%1$d.jpg", i));
			}
			catch (IM4JavaException e)
			{
				LOG.debug(e.getMessage());
			}
			catch (IOException e)
			{
				LOG.debug(e.getMessage());
			}
			catch (InterruptedException e)
			{
				LOG.debug(e.getMessage());
			}
	  	counter += 1;
		}
	}

	public void crossFade(File tempdir, Slide previousSlide, Slide slide, long transitions)
	{
  	CompositeCmd composite = new CompositeCmd();
		String lastframe = tempdir.getAbsolutePath() + File.separator + String.format("video_%1$d.jpg", previousSlide.getEndFrame());
  	double counter = 0;
		for (long i = slide.getStartFrame(); i < slide.getStartFrame()+transitions; i++)
		{
	  	IMOperation op = new IMOperation();
			op.blend(100 - new Long(Math.round((counter*100.0)/(transitions*1.0))).intValue());
	  	op.addImage(lastframe);
			op.addImage(tempdir.getAbsolutePath() + File.separator + String.format("video_%1$d.jpg", i));
	 		op.addImage(tempdir.getAbsolutePath() + File.separator + String.format("video_%1$d.jpg", i));
			try
			{
				composite.run(op);
			}
			catch (IM4JavaException e)
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			catch (IOException e)
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			catch (InterruptedException e)
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	  	counter += 1;
		}
	}

//	public void fade(File tempdir, String src, String dst, String output, double pct)
	public void fade(File tempdir, Slide previousSlide, Slide slide, long transitions)
	{
		String black = tempdir.getAbsolutePath() + File.separator + "blackimage.jpg";
		String lastframe = tempdir.getAbsolutePath() + File.separator + String.format("video_%1$d.jpg", previousSlide.getEndFrame());
  	CompositeCmd composite = new CompositeCmd();
  	double counter = 0;
		for (long i = slide.getStartFrame(); i < slide.getStartFrame()+transitions; i++)
		{
	  	IMOperation op = new IMOperation();
	  	if (i < transitions/2.0)
	  	{
	  		op.blend(100 - new Long(Math.round((counter*100.0)/(transitions*1.0))).intValue()*2);
	    	op.addImage();
	  		op.addImage();
	   		op.addImage();
	  		try
	  		{
	  			composite.run(op, lastframe, black, tempdir.getAbsolutePath() + File.separator + String.format("video_%1$d.jpg", i));
	  		}
	  		catch (IM4JavaException e)
	  		{
	  			// TODO Auto-generated catch block
	  			LOG.debug(e.getMessage());
	  		}
	  		catch (IOException e)
	  		{
	  			// TODO Auto-generated catch block
	  			LOG.debug(e.getMessage());
	  		}
	  		catch (InterruptedException e)
	  		{
	  			// TODO Auto-generated catch block
	  			LOG.debug(e.getMessage());
	  		}
	  	}
	  	else
	  	{
	  		op.blend(new Long(Math.round(counter/transitions)).intValue()*2-100);
	    	op.addImage();
	  		op.addImage();
	   		op.addImage();
	  		try
	  		{
	  			composite.run(op, tempdir.getAbsolutePath() + File.separator + String.format("video_%1$d.jpg", i), black, tempdir.getAbsolutePath() + File.separator + String.format("video_%1$d.jpg", i));
	  		}
	  		catch (IM4JavaException e)
	  		{
	  			// TODO Auto-generated catch block
	  			LOG.debug(e.getMessage());
	  		}
	  		catch (IOException e)
	  		{
	  			// TODO Auto-generated catch block
	  			LOG.debug(e.getMessage());
	  		}
	  		catch (InterruptedException e)
	  		{
	  			// TODO Auto-generated catch block
	  			LOG.debug(e.getMessage());
	  		}
	  	}
	  	counter += 1;
		}
	}

	public static void copyFile(File in, File out) throws IOException 
	{
	  FileChannel inChannel = new
	      FileInputStream(in).getChannel();
	  FileChannel outChannel = new
	      FileOutputStream(out).getChannel();
	  try {
	      inChannel.transferTo(0, inChannel.size(),
	              outChannel);
	  } 
	  catch (IOException e) {
	      throw e;
	  }
	  finally {
	      if (inChannel != null) inChannel.close();
	      if (outChannel != null) outChannel.close();
	  }
	}
	
	private void sendInfoMail(String to, int id)
	{
    String from = props.getProperty("mail.from");
    Properties properties = System.getProperties();
    properties.setProperty("mail.smtp.host", props.getProperty("mail.smtp.host"));
    Session session = Session.getDefaultInstance(properties);

    try{
       MimeMessage message = new MimeMessage(session);
       message.setFrom(new InternetAddress(from));
       message.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
       message.setSubject("[mmslides] Your video is ready for download");
       message.setText(String.format("Your video has been created successfully. You can download it for the next %1$d hours from the URL %2$s?id=%3$d", (int)(timelimit/(1000.0*60*60)), props.getProperty("moviedownloader"), id));
       Transport.send(message);
       LOG.debug("Sent message successfully....");
    }
    catch (MessagingException mex) 
    {
       mex.printStackTrace();
    }
	}

	public void ffmpeg(ArrayList<String> params, String workingdir)
	{
    try 
    {
      StringBuilder buf = new StringBuilder();
      for (String each: params) buf.append(" ").append(each);
      String paramString = buf.toString();

    	Process p = Runtime.getRuntime().exec(props.getProperty("ffmpeg.app") + " " + paramString, new String[0], new File(workingdir));
      InputHandler errorHandler = new InputHandler(p.getErrorStream(), "Error Stream");
      errorHandler.start();
      InputHandler inputHandler = new InputHandler(p.getInputStream(), "Output Stream");
      inputHandler.start();
      try 
      {
				p.waitFor();
      } 
      catch (InterruptedException e) 
      {
				throw new IOException("process interrupted");
      }
    }
    catch (Exception err) 
    {
      err.printStackTrace();
    }
	}

	public String makeVideo(File tempdir, String projectdir, String format, String filename, String extension, int width, int height, String audiofile)
	{
    try {
      String videofile = null;
      ArrayList<String> params = new ArrayList<String>();
      File audio = new File(tempdir.getAbsolutePath() + File.separator + audiofile);
      File projectDirectory = new File(props.getProperty("movie.dir") + File.separator + projectdir);
      if (!projectDirectory.exists())
      {
      	projectDirectory.mkdirs();
      }
      if (format.equals("h.264"))
      {
      	params.add("-y");
        params.add("-r " + String.format("%1$d", (int)fps));
        params.add("-i video_%d.jpg");
				params.add("-an");
        params.add(String.format("-s %1$dx%2$d", width, height));
      	params.add("-vcodec libx264");
				params.add("-vpre slow");
				if (width>640 || height>480) {
					params.add("-b 1800k");
				} else {
					params.add("-b 1200k");		
					params.add("-vpre ipod640");
				}
      	params.add("-aspect 4:3");
      	params.add("-threads 0");
      	params.add("-f mp4");
      	params.add("-acodec libfaac");
      	params.add("-ab 128k");
      	params.add("-ar 48000");
        params.add("-r " + String.format("%1$d", (int)fps));
      	//extension = ".m4v";
        if (audio.exists())
        {
          String videofile_without_audio = tempdir.getAbsolutePath() + File.separator + "tmpvideo" + extension;
          params.add(videofile_without_audio);
        	ffmpeg(params, tempdir.getAbsolutePath());
        	params.clear();
        	params.add("-y");
          params.add("-i " + audio.getAbsolutePath());
        	params.add("-acodec libfaac");
        	params.add("-ab 128k");
        	params.add("-ar 48000");
          String audio_aac = tempdir.getAbsolutePath() + File.separator + "tmpaudio.m4a";
          params.add(audio_aac);
        	ffmpeg(params, tempdir.getAbsolutePath());
          videofile = props.getProperty("movie.dir") + File.separator + projectdir + File.separator + filename + extension;
        	params.clear();
        	params.add("-y");
        	params.add("-vcodec copy");
          params.add("-i " + audio_aac);
          params.add("-i " + videofile_without_audio);
          params.add(videofile);
        	ffmpeg(params, tempdir.getAbsolutePath());
        }
        else
        {
          videofile = props.getProperty("movie.dir") + File.separator + projectdir + File.separator + filename + extension;
          params.add(videofile);
        	ffmpeg(params, tempdir.getAbsolutePath());
        }
      }
      else if (format.equals("flv")) { //FLV export
    	  params.add("-y");
          params.add("-r " + String.format("%1$d", (int)fps));
          params.add("-qscale 1");
        //  params.add("-f flv");
        //  params.add("-vcodec vp6f");
          params.add(String.format("-s %1$dx%2$d", width, height));
          params.add("-i video_%d.jpg");
          if (audio.exists())
          {
         //    params.add("-acodec mp3");
             params.add("-ab 128k");
             params.add("-ac 2");
             params.add("-i " + audio.getAbsolutePath());
          }
          videofile = props.getProperty("movie.dir") + File.separator + projectdir + File.separator + filename + extension;
          params.add(videofile);
          File f = new File(videofile);
          if (f.exists()) f.delete();
        ffmpeg(params, tempdir.getAbsolutePath());
      }
      else  //MPEG 4 compression - currently unused
      {
      	params.add("-y");
        params.add("-r " + String.format("%1$d", (int)fps));
      	params.add("-b 9600");
      	params.add("-qscale 1");
        params.add(String.format("-s %1$dx%2$d", width, height));
        params.add("-i video_%d.jpg");
        if (audio.exists())
        {
           params.add("-ab 128k");
           params.add("-acodec libfaac");
           params.add("-ac 2");
           params.add("-i " + audio.getAbsolutePath());
        }
        videofile = props.getProperty("movie.dir") + File.separator + projectdir + File.separator + filename + extension;
        params.add(videofile);
        File f = new File(videofile);
        if (f.exists()) f.delete();
      	ffmpeg(params, tempdir.getAbsolutePath());
      }
      File f = new File(videofile);
      if (f.exists())
      {
        return videofile;
      }
      else
      {
      	return null;
      }
    }
    catch (Exception err) 
    {
      err.printStackTrace();
      return null;
    }
	}

	public static boolean isAlive( Process p ) 
	{
		try
		{
			p.exitValue();
			return false;
		} 
		catch (IllegalThreadStateException e) 
		{
			return true;
		}
	}

	
	public static void clearFolder(String strFolder, boolean imagesOnly)
	{
		File directory = new File(strFolder);
		
		File[] files;
		if (imagesOnly)
		{
			files = directory.listFiles(new ImageFileFilter());
		}
		else
		{
			files = directory.listFiles();
		}
		for (File file : files)
		{
			if (!file.delete())
			{
				LOG.debug("Failed to delete "+file);
			}
		}
	}
	
	/**
	 * Create a new temporary directory. Use something like
	 * {@link #recursiveDelete(File)} to clean this directory up since it isn't
	 * deleted automatically
	 * @return  the new directory
	 * @throws IOException if there is an error creating the temporary directory
	 */
	public File createTempDir() throws IOException
	{
	    final File sysTempDir = new File(props.getProperty("movie.dir"));
	    File newTempDir;
	    final int maxAttempts = 9;
	    int attemptCount = 0;
	    do
	    {
	        attemptCount++;
	        if(attemptCount > maxAttempts)
	        {
	            throw new IOException(
	                    "The highly improbable has occurred! Failed to " +
	                    "create a unique temporary directory after " +
	                    maxAttempts + " attempts.");
	        }
	        String dirName = UUID.randomUUID().toString();
	        newTempDir = new File(sysTempDir, dirName);
	    } while(newTempDir.exists());

	    if(newTempDir.mkdirs())
	    {
	        return newTempDir;
	    }
	    else
	    {
	        throw new IOException(
	                "Failed to create temp dir named " +
	                newTempDir.getAbsolutePath());
	    }
	}

	/**
	 * Recursively delete file or directory
	 * @param fileOrDir
	 *          the file or dir to delete
	 * @return
	 *          true iff all files are successfully deleted
	 */
	public boolean recursiveDelete(File fileOrDir)
	{
	    if(fileOrDir.isDirectory())
	    {
	        // recursively delete contents
	        for(File innerFile: fileOrDir.listFiles())
	        {
	            if(!recursiveDelete(innerFile))
	            {
	                return false;
	            }
	        }
	    }

	    return fileOrDir.delete();
	}
	
	public synchronized void makeMovie(JSONObject object)
	{
    LOG.debug("Making movie images");
    File tempdir;
    try
		{
			tempdir = createTempDir();
		}
		catch (IOException e1)
		{
			LOG.error("Could not create temporary directory");
			return;
		}
    JSONArray slides = arrayForKey(objectForKey(objectForKey(object, "data"), "data"), "slides");
    String webroot = (String)object.get("project_webroot");
    String projectpath = (String)objectForKey(object, "data").get("path");
    Long width = (Long)objectForKey(object, "exportsettings").get("width");
    Long height = (Long)objectForKey(object, "exportsettings").get("height");
    Double fullLength;
        if (objectForKey(objectForKey(object, "data"), "data").get("length").getClass() == Long.class)
        {
fullLength = ((Long)objectForKey(objectForKey(object, "data"), "data").get("length")).doubleValue();
        }
        else
        {
fullLength = (Double)objectForKey(objectForKey(object, "data"), "data").get("length");
        }
    String format = (String)objectForKey(object, "exportsettings").get("videoFormat");
    String extension = (String)objectForKey(object, "exportsettings").get("extension");
    boolean showCaptions = ((Boolean)objectForKey(object, "exportsettings").get("showCaptionsByDefault")).booleanValue() !=false;
    String projectname = (String)objectForKey(object, "data").get("project");
    String audiofile = null;
    try
    {
    	audiofile = (String)objectForKey(objectForKey(objectForKey(objectForKey(object, "data"), "data"), "meta"), "audio").get("file");
    	copyFile(new File(webroot + projectpath + File.separator + audiofile), new File(tempdir.getAbsolutePath() + File.separator + audiofile));
    }
    catch (NullPointerException e)
    {
    	LOG.debug("No audio file found");
    }
		catch (IOException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
   // String recipient = "helmut.schottmueller@me.com";
    String recipient = (String)object.get("email");

    projectname.replaceAll("\\s", "_");
    projectname.replaceAll("^[a-zA-z]", "");
    projectname += "_" + width.intValue() + "_" + height.intValue();
    ArrayList<Slide> slidelist = new ArrayList<Slide>();
    for (Iterator i = slides.iterator(); i.hasNext();) 
    {
    	JSONObject obj = (JSONObject)i.next();
    	Slide slide = new Slide();
    	slide.setFilepath(webroot + projectpath + File.separator + width.toString() + File.separator + (String) obj.get("file"));
    	slide.setFilepathFullResolution(webroot + projectpath + File.separator + "1280" + File.separator + (String) obj.get("file"));
    	if (showCaptions) slide.setCaption((String)obj.get("caption"));
    	if (objectForKey(obj, "transition") != null)
    	{
      	slide.setTransition((String)objectForKey(obj, "transition").get("type"));
      	if (objectForKey(obj, "transition").get("length").getClass() == Long.class)
      	{
        	slide.setTransitionlength(((Long)objectForKey(obj, "transition").get("length")).doubleValue());
      	}
      	else
      	{
        	slide.setTransitionlength(((Double)objectForKey(obj, "transition").get("length")));
      	}
    	}
    	if (objectForKey(obj, "kenburns") != null && obj.get("iskenburns") != null && ((Boolean)obj.get("iskenburns")).booleanValue() != false)
    	{
    		slide.setKenBurns(true);
      	if (objectForKey(obj, "kenburns").get("s.x").getClass() == Long.class)
      	{
      		slide.setStartX(((Long)objectForKey(obj, "kenburns").get("s.x")).doubleValue() * 1280.0/460.0);
      	}
      	else
      	{
      		slide.setStartX(((Double)objectForKey(obj, "kenburns").get("s.x")).doubleValue() * 1280.0/460.0);
      	}
      	if (objectForKey(obj, "kenburns").get("s.y").getClass() == Long.class)
      	{
      		slide.setStartY(((Long)objectForKey(obj, "kenburns").get("s.y")).doubleValue() * 1280.0/460.0);
      	}
      	else
      	{
      		slide.setStartY(((Double)objectForKey(obj, "kenburns").get("s.y")).doubleValue() * 1280.0/460.0);
      	}
      	if (objectForKey(obj, "kenburns").get("s.w").getClass() == Long.class)
      	{
      		slide.setStartW(((Long)objectForKey(obj, "kenburns").get("s.w")).doubleValue() * 1280.0/460.0);
      	}
      	else
      	{
      		slide.setStartW(((Double)objectForKey(obj, "kenburns").get("s.w")).doubleValue() * 1280.0/460.0);
      	}
      	if (objectForKey(obj, "kenburns").get("s.h").getClass() == Long.class)
      	{
      		slide.setStartH(((Long)objectForKey(obj, "kenburns").get("s.h")).doubleValue() * 1280.0/460.0);
      	}
      	else
      	{
      		slide.setStartH(((Double)objectForKey(obj, "kenburns").get("s.h")).doubleValue() * 1280.0/460.0);
      	}
      	if (objectForKey(obj, "kenburns").get("e.x").getClass() == Long.class)
      	{
      		slide.setEndX(((Long)objectForKey(obj, "kenburns").get("e.x")).doubleValue() * 1280.0/460.0);
      	}
      	else
      	{
      		slide.setEndX(((Double)objectForKey(obj, "kenburns").get("e.x")).doubleValue() * 1280.0/460.0);
      	}
      	if (objectForKey(obj, "kenburns").get("e.y").getClass() == Long.class)
      	{
      		slide.setEndY(((Long)objectForKey(obj, "kenburns").get("e.y")).doubleValue() * 1280.0/460.0);
      	}
      	else
      	{
      		slide.setEndY(((Double)objectForKey(obj, "kenburns").get("e.y")).doubleValue() * 1280.0/460.0);
      	}
      	if (objectForKey(obj, "kenburns").get("e.w").getClass() == Long.class)
      	{
      		slide.setEndW(((Long)objectForKey(obj, "kenburns").get("e.w")).doubleValue() * 1280.0/460.0);
      	}
      	else
      	{
      		slide.setEndW(((Double)objectForKey(obj, "kenburns").get("e.w")).doubleValue() * 1280.0/460.0);
      	}
      	if (objectForKey(obj, "kenburns").get("e.h").getClass() == Long.class)
      	{
      		slide.setEndH(((Long)objectForKey(obj, "kenburns").get("e.h")).doubleValue() * 1280.0/460.0);
      	}
      	else
      	{
      		slide.setEndH(((Double)objectForKey(obj, "kenburns").get("e.h")).doubleValue() * 1280.0/460.0);
      	}
    		//LOG.debug(String.format("SLIDE: s.x %1$.2f s.y %2$.2f s.w %3$.2f s.h %4$.2f, e.x %5$.2f e.y %6$.2f e.w %7$.2f e.h %8$.2f", slide.getStartX(), slide.getStartY(),slide.getStartW(),slide.getStartH(),slide.getEndX(),slide.getEndY(),slide.getEndW(),slide.getEndH()));
    	}
    	else
    	{
    		slide.setKenBurns(false);
    	}
    	if (obj.get("length").getClass() == Long.class)
    	{
      	slide.setLength(((Long)obj.get("length")).doubleValue());
    	}
    	else
    	{
      	slide.setLength((Double)obj.get("length"));
    	}
    	slidelist.add(slide);
    }

    long imagecounter = 1;
  	ConvertCmd cmd = new ConvertCmd();
  	CompositeCmd composite = new CompositeCmd();
  	// Create a black image for background operations
  	IMOperation blackop = new IMOperation();
  	blackop.size(width.intValue(), height.intValue());
  	blackop.addImage("xc:black");
  	blackop.addImage(tempdir.getAbsolutePath() + File.separator + "blackimage.jpg");
		try
		{
			cmd.run(blackop);
		}
		catch (IM4JavaException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		catch (IOException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		catch (InterruptedException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

  	for (Iterator i = slidelist.iterator(); i.hasNext();)
    {
  		File tempfile = null;
    	Slide slide = (Slide) i.next();
    	slide.setStartFrame(imagecounter);
  		double slidelen = slide.getLength().doubleValue(); 
    	double maximages = Math.round((slidelen/1000.0)*fps);
      LOG.debug("Processing movie/Ken Burns images for slide");
  		for (int dup = 0; dup < maximages; dup++)
  		{
  			if (slide.isKenBurns())
  			{
    			File src = new File(slide.getFilepathFullResolution());
    			File dst = new File(tempdir.getAbsolutePath() + File.separator + String.format("video_%1$d.jpg", imagecounter));
    			double[] r = slide.getRectForPercentage(dup/maximages);
  				kenBurns(src, dst, r[0], r[1], r[2], r[3], width.doubleValue(), height.doubleValue());
  				if (slide.getCaption() != null && slide.getCaption().length() > 0)
  				{
  					addLabel(dst.getAbsolutePath(), slide.getCaption(), width.intValue());
  				}
  			}
  			else
  			{
  				if (tempfile == null)
  				{
      			tempfile = new File(tempdir.getAbsolutePath() + File.separator + "tempfile.jpg");
      			try
						{
							copyFile(new File(slide.getFilepath()), tempfile);
		  				if (slide.getCaption() != null && slide.getCaption().length() > 0)
		  				{
		  					addLabel(tempfile.getAbsolutePath(), slide.getCaption(), width.intValue());
		  				}
						}
						catch (IOException e)
						{
							tempfile = null;
							e.printStackTrace();
						}
  				}
    			File src = tempfile;
    			File dst = new File(tempdir.getAbsolutePath() + File.separator + String.format("video_%1$d.jpg", imagecounter));
    			try
  				{
  					copyFile(src, dst);
  				}
  				catch (IOException e)
  				{
  					// TODO Auto-generated catch block
  					e.printStackTrace();
  				}
  			}
				imagecounter++;
  		}
  		slide.setEndFrame(imagecounter-1);
    }

  	imagecounter = 1;
  	Slide previousSlide = null;
  	double lengthOfSlides = 0.0;
  	for (Iterator i = slidelist.iterator(); i.hasNext();)
    {
      LOG.debug("Processing transition images for slide " + imagecounter);
    	Slide slide = (Slide) i.next();
    	lengthOfSlides += slide.getLength().doubleValue();
  		double slidelen = slide.getLength().doubleValue()/1000.0; 
    	if (previousSlide != null && previousSlide.getTransition() != null && previousSlide.getTransition().length() > 0 && previousSlide.getTransitionlength() != null && previousSlide.getTransitionlength().doubleValue() > 0)
    	{
    		slidelen = slidelen - previousSlide.getTransitionlength()/1000.0;
    		double totaltrans = Math.round((previousSlide.getTransitionlength()/1000)*fps);
  			if (previousSlide.getTransition().equals("fade"))
  			{
    			fade(tempdir, previousSlide, slide, new Long(Math.round(totaltrans)).longValue());
  			}
  			else if (previousSlide.getTransition().equals("crossfade"))
  			{
    			crossFade(tempdir, previousSlide, slide, new Long(Math.round(totaltrans)).longValue());
  			}
  			else if (previousSlide.getTransition().equals("straightcut"))
  			{
  				slideleft(tempdir, previousSlide, slide, new Long(Math.round(totaltrans)).longValue(), width.intValue(), height.intValue());
  			}
    	}
  		imagecounter++;
    	previousSlide = slide;
    }
  	if (lengthOfSlides < fullLength)
  	{
  		double missingFrames = Math.round(((fullLength-lengthOfSlides)/1000)*fps);
  		Slide lastSlide = slidelist.get(slidelist.size()-1);
  		String black = tempdir.getAbsolutePath() + File.separator + "blackimage.jpg";
			File src = new File(black);
  		for (long i = lastSlide.getEndFrame()+1; i < lastSlide.getEndFrame()+1+missingFrames;i++)
  		{
  			File dst = new File(tempdir.getAbsolutePath() + File.separator + String.format("video_%1$d.jpg", i));
  			try
				{
					copyFile(src, dst);
				}
				catch (IOException e)
				{
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
  		}
  	}
    String filename = makeVideo(tempdir, projectpath, format, new Integer(movieID).toString(), extension, width.intValue(), height.intValue(), audiofile);
    if (filename != null)
    {
      String downloadPath = filename.replace(props.getProperty("movie.dir") + File.separator + projectpath + File.separator, props.getProperty("server.dir") + "/" + projectpath + "/");
      MovieData moviedata = new MovieData(filename);
      moviedata.setId(movieID);
      try
      {
        FileWriter w = new FileWriter(props.getProperty("movie.dir") + File.separator + movieID);
        /*
        String extension = ".avi";
        if (format.equals("h.264"))
        {
        	extension = ".m4v";
        }
       */ 
        w.write(filename + ":::" + projectname + extension);
        w.close();
      }
      catch (Exception e)
      {
				LOG.error("Could not create " + props.getProperty("movie.dir") + File.separator + movieID);
      }
      createdMovies.put(filename, moviedata);
      sendInfoMail(recipient, movieID);
      movieID++;
    }
    recursiveDelete(tempdir);
    LOG.debug(object);
	}

	@Override
	public void run()
	{
		long counter = 0;
    try 
    {
      while (true) 
      {
        String q = this.getNextQueueFile();
        if (q != null)
        {
					try
					{
	        	JSONObject object;
						object = (JSONObject)JSONValue.parse(this.fileToString(q));
						if (object != null)
						{
							makeMovie(object);
						}
	          File f = new File(q);
	          f.delete();
					}
					catch (IOException e)
					{
						// TODO Auto-generated catch block
						e.printStackTrace();
					}       
        }
        if (counter % 36 == 0) // every three minutes
        {
          purgeCreatedMovies();
        }
        Thread.sleep(5000);
        counter++;
  		}
    }
    catch (InterruptedException e) 
  	{
  	}
	}
}
