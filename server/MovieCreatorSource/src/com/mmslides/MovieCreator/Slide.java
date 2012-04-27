/*
 * Slide.java
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

import org.apache.log4j.Logger;

public class Slide
{
	private static Logger LOG = Logger.getLogger(Slide.class); 

	private String filepath;
	private String filepathFullResolution;
	private String transition;
	private Double transitionlength;
	private Double length;
	private String caption;
	private Double startX;
	private Double startY;
	private Double startW;
	private Double startH;
	private Double endX;
	private Double endY;
	private Double endW;
	private Double endH;
	private long startFrame;
	private long endFrame;
	
	/**
	 * @return the startFrame
	 */
	public long getStartFrame()
	{
		return startFrame;
	}
	/**
	 * @param startFrame the startFrame to set
	 */
	public void setStartFrame(long startFrame)
	{
		this.startFrame = startFrame;
	}
	/**
	 * @return the endFrame
	 */
	public long getEndFrame()
	{
		return endFrame;
	}
	/**
	 * @param endFrame the endFrame to set
	 */
	public void setEndFrame(long endFrame)
	{
		this.endFrame = endFrame;
	}
	/**
	 * @return the filepathFullResolution
	 */
	public String getFilepathFullResolution()
	{
		return filepathFullResolution;
	}
	/**
	 * @param filepathFullResolution the filepathFullResolution to set
	 */
	public void setFilepathFullResolution(String filepathFullResolution)
	{
		this.filepathFullResolution = filepathFullResolution;
	}

	/**
	 * @return the startX
	 */
	public Double getStartX()
	{
		return startX;
	}
	/**
	 * @param startX the startX to set
	 */
	public void setStartX(Double startX)
	{
		this.startX = startX;
	}
	/**
	 * @return the startY
	 */
	public Double getStartY()
	{
		return startY;
	}
	/**
	 * @param startY the startY to set
	 */
	public void setStartY(Double startY)
	{
		this.startY = startY;
	}
	/**
	 * @return the startW
	 */
	public Double getStartW()
	{
		return startW;
	}
	/**
	 * @param startW the startW to set
	 */
	public void setStartW(Double startW)
	{
		this.startW = startW;
	}
	/**
	 * @return the startH
	 */
	public Double getStartH()
	{
		return startH;
	}
	/**
	 * @param startH the startH to set
	 */
	public void setStartH(Double startH)
	{
		this.startH = startH;
	}
	/**
	 * @return the endX
	 */
	public Double getEndX()
	{
		return endX;
	}
	/**
	 * @param endX the endX to set
	 */
	public void setEndX(Double endX)
	{
		this.endX = endX;
	}
	/**
	 * @return the endY
	 */
	public Double getEndY()
	{
		return endY;
	}
	/**
	 * @param endY the endY to set
	 */
	public void setEndY(Double endY)
	{
		this.endY = endY;
	}
	/**
	 * @return the endW
	 */
	public Double getEndW()
	{
		return endW;
	}
	/**
	 * @param endW the endW to set
	 */
	public void setEndW(Double endW)
	{
		this.endW = endW;
	}
	/**
	 * @return the endH
	 */
	public Double getEndH()
	{
		return endH;
	}
	/**
	 * @param endH the endH to set
	 */
	public void setEndH(Double endH)
	{
		this.endH = endH;
	}

	private boolean kenBurns;
	
	/**
	 * @return the kenBurns
	 */
	public boolean isKenBurns()
	{
		return kenBurns;
	}
	/**
	 * @param kenBurns the kenBurns to set
	 */
	public void setKenBurns(boolean kenBurns)
	{
		this.kenBurns = kenBurns;
	}

	/**
	 * @return the filepath
	 */
	public String getFilepath()
	{
		return filepath;
	}
	/**
	 * @param filepath the filepath to set
	 */
	public void setFilepath(String filepath)
	{
		this.filepath = filepath;
	}
	/**
	 * @return the transition
	 */
	public String getTransition()
	{
		return transition;
	}
	/**
	 * @param transition the transition to set
	 */
	public void setTransition(String transition)
	{
		this.transition = transition;
	}
	/**
	 * @return the transitionlength
	 */
	public Double getTransitionlength()
	{
		return transitionlength;
	}
	/**
	 * @param transitionlength the transitionlength to set
	 */
	public void setTransitionlength(Double transitionlength)
	{
		this.transitionlength = transitionlength;
	}
	/**
	 * @return the length
	 */
	public Double getLength()
	{
		return length;
	}
	/**
	 * @param length the length to set
	 */
	public void setLength(Double length)
	{
		this.length = length;
	}
	/**
	 * @return the caption
	 */
	public String getCaption()
	{
		return caption;
	}
	/**
	 * @param caption the caption to set
	 */
	public void setCaption(String caption)
	{
		this.caption = caption;
	}
	
	public double[] getRectForPercentage(double percentage)
	{
		double[] rect = new double[4];
		double c_s_x = startX + startW/2.0;
		double c_s_y = startY + startH/2.0;
		double c_e_x = endX + endW/2.0;
		double c_e_y = endY + endH/2.0;
		double m = 0;
		if (c_e_x - c_s_x != 0)
		{
			m = (c_e_y - c_s_y)/(c_e_x - c_s_x);
		}
		double n = c_s_y - m*c_s_x;
		double scale = endW/startW;
		double p_x = c_s_x + (c_e_x - c_s_x)*percentage;
		double p_y = m * p_x + n;
		if (m == 0)
		{
			if (c_e_y < c_s_y)
			{
				p_y = c_s_y - (c_s_y-c_e_y)*percentage;
			}
			else
			{
				p_y = c_s_y + (c_e_y - c_s_y)*percentage;
			}
		}
		double factor = 1.0+((scale-1.0)*percentage);
		double dx = startW*factor;
		double dy = startH*factor;
		rect[0] = p_x - dx/2.0;
		rect[1] = p_y - dy/2.0;
		rect[2] = dx;
		rect[3] = dy;
		//LOG.debug(String.format("x %1$.2f y %2$.2f w %3$.2f h %4$.2f, percentage %5$.2f", rect[0], rect[1], rect[2], rect[3], percentage*100.0));
		return rect;
	}
	
	public String toString()
	{
		return String.format("%1$s %2$f %3$s %4$s %5$f", filepath, length, caption, transition, transitionlength);
	}
}
