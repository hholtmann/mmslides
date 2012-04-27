/*
 * MailAuthenticator.java
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

import javax.mail.Authenticator;
import javax.mail.PasswordAuthentication;

class MailAuthenticator extends Authenticator {
	 
  /**
   * Ein String, der den Usernamen nach der Erzeugung eines
   * Objektes<br>
   * dieser Klasse enthalten wird.
   */
  private final String user;

  /**
   * Ein String, der das Passwort nach der Erzeugung eines
   * Objektes<br>
   * dieser Klasse enthalten wird.
   */
  private final String password;

  /**
   * Der Konstruktor erzeugt ein MailAuthenticator Objekt<br>
   * aus den beiden Parametern user und passwort.
   * 
   * @param user
   *            String, der Username fuer den Mailaccount.
   * @param password
   *            String, das Passwort fuer den Mailaccount.
   */
  public MailAuthenticator(String user, String password) {
      this.user = user;
      this.password = password;
  }

  /**
   * Diese Methode gibt ein neues PasswortAuthentication
   * Objekt zurueck.
   * 
   * @see javax.mail.Authenticator#getPasswordAuthentication()
   */
  protected PasswordAuthentication getPasswordAuthentication() {
      return new PasswordAuthentication(this.user, this.password);
  }
}
