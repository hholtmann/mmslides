/*
 * LoginDialogController.j
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


@import <Foundation/CPObject.j>
@import <Foundation/CPDictionary.j>
@import <AppKit/CPWindowController.j>
@import "CPFocusTextField.j"
@import "MHPopUpButton.j"
@import "LPAnchorButton.j"

LM_LOGIN = 0;
LM_REGISTRATION = 1;
LM_REGISTRATION_FINISH = 3;
LM_LOSTPASSWORD = 2;

LD_ERROR_NO_ERROR = 0;
LD_ERROR_MISSING_USERNAME = 1;
LD_ERROR_MISSING_PASSWORD = 2;
LD_ERROR_MISSING_PASSWORD_CONFIRMATION = 3;
LD_ERROR_MISSING_EMAIL = 4;
LD_ERROR_WRONG_USERNAME_OR_PASSWORD = 5;
LD_ERROR_WRONG_USERNAME = 6;
LD_ERROR_WRONG_PASSWORD = 7;
LD_ERROR_WRONG_PASSWORD_CONFIRMATION = 8;
LD_ERROR_WRONG_EMAIL = 9;
LD_ERROR_USERNAME_EXISTS = 10;
LD_ERROR_REGISTRATION_FAILED = 11;
LD_ERROR_LOSTPASSWORD_FAILED = 12;
LD_ERROR_MISSING_FIRSTNAME = 13;
LD_ERROR_MISSING_LASTNAME = 14;
LD_ERROR_MISSING_EMAIL_CONFIRMATION = 15;
LD_ERROR_WRONG_EMAIL_CONFIRMATION = 16;
LD_ERROR_MISSING_ORGANIZATION = 17;
LD_ERROR_MISSING_PHONE = 18;
LD_ERROR_MISSING_SECURITYRESULT = 19;
LD_ERROR_WRONG_SECURITYRESULT = 20;
LD_ERROR_LICENSE_AGREEMENT = 21;

@implementation LoginDialogController : CPWindowController
{
	CPButton _registerButton;
	CPButton _okButton;
	CPButton _cancelButton;
	CPButton _passwordTroubles;
	CPTextField _description;
	CPTextField _contactDescription;
	CPTextField _lostPasswordDescription;
	CPTextField _username;
	CPFocusTextField _usernameLabel;
	CPTextField _password;
	CPFocusTextField _passwordLabel;
	CPTextField _passwordConfirmation;
	CPFocusTextField _passwordConfirmationLabel;
	CPTextField _email;
	CPFocusTextField _emailLabel;
	
	CPTextField _emailConfirm;
	CPFocusTextField _emailConfirmLabel;
	
	CPTextField _firstName;
	CPFocusTextField _firstNameLabel;
	CPTextField _lastName;
	CPFocusTextField _lastNameLabel;
	
	CPTextField _organization;
	CPFocusTextField _organizationLabel;
	
	CPTextField _phone;
	CPFocusTextField _phoneLabel;
	
	CPTextField _security;
	CPFocusTextField _securityLabel;
	CPFocusTextField _securityResult;
	
	MHPopUpButton _country;
	CPTextField  _countryLabel;
	
	CPColor _errorColor;
	CPColor _textColor;
	id _delegate @accessors(property=delegate);
	BOOL _loginMode @accessors(property=loginMode);
	int _error @accessors(property=error);
	int _contentWidth;	
	int _initialY;
	
	CPArray allControls;
	CPArray loginControls;
	CPArray registerControls;
	CPArray contactControls;
	CPArray lostControls;
	
	CPCheckBox _usageTerms;
	

	var countries;
	int selectedCountry;
	int securityResultNum;
	
	CPString _usernameConfirmed;
	CPString _passwordConfirmed;
}


-(void)countrySelected:(id)sender
{
	selectedCountry = [sender tag];
}

-(void)loadCountries
{
	var data = [CPURLConnection sendSynchronousRequest:[CPURLRequest requestWithURL:[CPURL URLWithString:@"Resources/countries.json"]] returningResponse:nil];
	countries = [data JSONObject];
}

- (id)init
{
	var theWindow = [[CPPanel alloc] initWithContentRect:CGRectMake(80, 80, 400, 200) styleMask:CPClosableWindowMask];
	self = [super initWithWindow:theWindow];
    _initialY = 0;
	if (self)
	{
		
		allControls = [CPArray array];
		loginControls = [CPArray array];
		lostControls = [CPArray array];
		registerControls = [CPArray array];
		contactControls = [CPArray array];

		_loginMode = LM_LOGIN;
		
		[theWindow setTitle:CPLocalizedString(@"Login")];
		[theWindow setDelegate:self];
		[theWindow setFloatingPanel:YES];

		_contentWidth = 400;
		_error = LD_ERROR_NO_ERROR;
		_errorColor = [CPColor colorWithHexString:@"ff811d"];
		_textColor = [CPColor colorWithHexString:@"000000"];

		var contentView = [theWindow contentView]
		_description = [CPTextField labelWithTitle:@"Enter your username and password to login."];
		[_description setFrame:CGRectMake(0,5,_contentWidth-10,30)];
		[_description setAlignment:CPCenterTextAlignment];
		[_description setFont:[CPFont systemFontOfSize:15.0]];
		[contentView addSubview:_description];
		[allControls addObject:_description];
		[loginControls addObject:_description];
		[lostControls addObject:_description];
		[registerControls addObject:_description];
		[contactControls addObject:_description];

		_contactDescription = [CPTextField labelWithTitle:@"Contact Info:"];
		[_contactDescription setFrame:CGRectMake(0,170,_contentWidth-10,30)];
		[_contactDescription setAlignment:CPCenterTextAlignment];
		[_contactDescription setFont:[CPFont systemFontOfSize:15.0]];
		[_contactDescription setHidden:YES];
		[contentView addSubview:_contactDescription];
		[allControls addObject:_contactDescription];
		
		_lostPasswordDescription = [CPTextField labelWithTitle:@"Enter your email address and we'll send you instructions on how to reset your password."];
		[_lostPasswordDescription setFrame:CGRectMake(0,5,_contentWidth-10,80)];
		[_lostPasswordDescription setAlignment:CPCenterTextAlignment];
		[_lostPasswordDescription setFont:[CPFont systemFontOfSize:15.0]];
		[_lostPasswordDescription setLineBreakMode:CPLineBreakByWordWrapping];
		[_lostPasswordDescription setHidden:YES];
		[contentView addSubview:_lostPasswordDescription];
		[allControls addObject:_lostPasswordDescription];
		[lostControls addObject:_lostPasswordDescription];

		
		_username = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"") width:200]
		[_username setFrame:CGRectMake(_contentWidth-20-250,40, 200, 30)];
		[_username setEditable:YES]; 
		[_username setTarget:self]; 
		[_username setAction:@selector(textFieldDidEndEditing:)];
		[_username setFont:[CPFont systemFontOfSize:14.0]];
		[_username setDelegate:self]; 
		[contentView addSubview:_username];
		[allControls addObject:_username];
		[loginControls addObject:_username];
		[registerControls addObject:_username];

		
		_usernameLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Username:")];
		[_usernameLabel setFrame:CGRectMake(5, 46, 120, 24)];
		[_usernameLabel setFocusField:_username];
		[_usernameLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_usernameLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[contentView addSubview:_usernameLabel];
		[allControls addObject:_usernameLabel];
		[loginControls addObject:_usernameLabel];
		[registerControls addObject:_usernameLabel];


		_password = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"") width:200]
		[_password setFrame:CGRectMake(_contentWidth-20-250, 80, 200, 30)];
		[_password setEditable:YES]; 
		[_password setSecure:YES];
		[_password setTarget:self]; 
		[_password setFont:[CPFont systemFontOfSize:14.0]];
		[_password setAction:@selector(textFieldDidEndEditing:)];
		[_password setDelegate:self]; 
		[contentView addSubview:_password];
		[allControls addObject:_password];
		[loginControls addObject:_password];
		[registerControls addObject:_password];

		_passwordLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Password:")];
		[_passwordLabel setFrame:CGRectMake(5, 86, 120, 24)];
		[_passwordLabel setFocusField:_password];
		[_passwordLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_passwordLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[contentView addSubview:_passwordLabel];
		[allControls addObject:_passwordLabel];
		[loginControls addObject:_passwordLabel];
		[registerControls addObject:_passwordLabel];


		_passwordConfirmation = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"") width:200]
		[_passwordConfirmation setFrame:CGRectMake(_contentWidth-20-250, 120, 200, 30)];
		[_passwordConfirmation setEditable:YES]; 
		[_passwordConfirmation setSecure:YES];
		[_passwordConfirmation setTarget:self]; 
		[_passwordConfirmation setFont:[CPFont systemFontOfSize:14.0]];
		[_passwordConfirmation setAction:@selector(textFieldDidEndEditing:)];
		[_passwordConfirmation setDelegate:self];
		[_passwordConfirmation setHidden:YES];
		[contentView addSubview:_passwordConfirmation];
		[allControls addObject:_passwordConfirmation];
		[registerControls addObject:_passwordConfirmation];

		_passwordConfirmationLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Confirm:")];
		[_passwordConfirmationLabel setFrame:CGRectMake(5, 126, 120, 24)];
		[_passwordConfirmationLabel setFocusField:_passwordConfirmation];
		[_passwordConfirmationLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_passwordConfirmationLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_passwordConfirmationLabel setHidden:YES];
		[contentView addSubview:_passwordConfirmationLabel];
		[allControls addObject:_passwordConfirmationLabel];
		[registerControls addObject:_passwordConfirmationLabel];

		_email = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"") width:200]
		[_email setFrame:CGRectMake(_contentWidth-20-250, 240, 200, 30)];
		[_email setEditable:YES]; 
		[_email setTarget:self]; 
		[_email setFont:[CPFont systemFontOfSize:14.0]];
		[_email setAction:@selector(textFieldDidEndEditing:)];
		[_email setDelegate:self];
		[_email setHidden:YES];
		[contentView addSubview:_email];
		[allControls addObject:_email];
		[lostControls addObject:_email];
		[contactControls addObject:_email];

		_emailLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Email:")];
		[_emailLabel setFrame:CGRectMake(5, 246, 126, 24)];
		[_emailLabel setFocusField:_email];
		[_emailLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_emailLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_emailLabel setHidden:YES];
		[contentView addSubview:_emailLabel];
		[allControls addObject:_emailLabel];
		[lostControls addObject:_emailLabel];
		[contactControls addObject:_emailLabel];


		//Organization
		_organization = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"") width:200]
		[_organization setFrame:CGRectMake(_contentWidth-20-250, 200, 200, 30)];
		[_organization setEditable:YES]; 
		[_organization setTarget:self]; 
		[_organization setFont:[CPFont systemFontOfSize:14.0]];
		[_organization setAction:@selector(textFieldDidEndEditing:)];
		[_organization setDelegate:self];
		[_organization setHidden:YES];
		[contentView addSubview:_organization];
		[allControls addObject:_organization];
		[contactControls addObject:_organization];

		_organizationLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Organization:")];
		[_organizationLabel setFrame:CGRectMake(5, 206, 126, 24)];
		[_organizationLabel setFocusField:_email];
		[_organizationLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_organizationLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_organizationLabel setHidden:YES];
		[contentView addSubview:_organizationLabel];
		[allControls addObject:_organizationLabel];
		[contactControls addObject:_organizationLabel];
		
		
		//phone
		_phone = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"") width:200]
		[_phone setFrame:CGRectMake(_contentWidth-20-250, 240, 200, 30)];
		[_phone setEditable:YES]; 
		[_phone setTarget:self]; 
		[_phone setFont:[CPFont systemFontOfSize:14.0]];
		[_phone setAction:@selector(textFieldDidEndEditing:)];
		[_phone setDelegate:self];
		[_phone setHidden:YES];
		[contentView addSubview:_phone];
		[allControls addObject:_phone];
		[contactControls addObject:_phone];
		
		_phoneLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Phone Number:")];
		[_phoneLabel setFrame:CGRectMake(5, 246, 126, 24)];
		[_phoneLabel setFocusField:_email];
		[_phoneLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_phoneLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_phoneLabel setHidden:YES];
		[contentView addSubview:_phoneLabel];
		[allControls addObject:_phoneLabel];
		[contactControls addObject:_phoneLabel];
		
		
		_security = [CPFocusTextField labelWithTitle:CPLocalizedString(@"")];
		[_security setFrame:CGRectMake(_contentWidth-20-248, 286, 200, 30)];
		[_security setFont:[CPFont systemFontOfSize:14.0]];
		[_security setHidden:YES];
		[_security setValue:CPLeftTextAlignment forThemeAttribute:@"alignment"];
		[contentView addSubview:_security];
		[allControls addObject:_security];
		[contactControls addObject:_security];
		
		//set Content
		var firstNum = Math.floor(Math.random()*100);
		var secondNum = Math.floor(Math.random()*100);
		securityResultNum = firstNum + secondNum;
		
		[_security setStringValue:firstNum+ " + " + secondNum+" = "];
		[_security sizeToFit];
		CPLog([_security frame].size.width);
		
		
		_securityResult = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"") width:45]
		[_securityResult setFrame:CGRectMake(_contentWidth-20-250+[_security frame].size.width, 280, 45, 30)];
		[_securityResult setEditable:YES]; 
		[_securityResult setTarget:self]; 
		[_securityResult setFont:[CPFont systemFontOfSize:14.0]];
		[_securityResult setAction:@selector(textFieldDidEndEditing:)];
		[_securityResult setDelegate:self];
		[_securityResult setHidden:YES];
		[contentView addSubview:_securityResult];
		[allControls addObject:_securityResult];
		[contactControls addObject:_securityResult];
		
		
		_securityLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Security:")];
		[_securityLabel setFrame:CGRectMake(5, 286, 126, 24)];
		[_securityLabel setFocusField:_email];
		[_securityLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_securityLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_securityLabel setHidden:YES];
		[contentView addSubview:_securityLabel];
		[allControls addObject:_securityLabel];
		[contactControls addObject:_securityLabel];
		
		
		//usageTerms
		_usageTerms = [CPCheckBox checkBoxWithTitle:@""];
		[_usageTerms setFrameOrigin:CGPointMake(115, 320)];
		[contentView addSubview:_usageTerms];
		[allControls addObject:_usageTerms];
		[contactControls addObject:_usageTerms];
		
		_usageTermsLabel =  [LPAnchorButton buttonWithTitle:@"Usage Terms"];
		[_usageTermsLabel setFrame:CGRectMake(135,170,150,24)];
		[_usageTermsLabel setValue:CPLeftTextAlignment forThemeAttribute:@"alignment"];
		[_usageTermsLabel setValue:CPCenterVerticalTextAlignment forThemeAttribute:@"vertical-alignment"];
		[_usageTermsLabel openURLOnClick:[CPURL URLWithString:@"../server/agreement.php"]];
		[_usageTermsLabel setHidden:NO];
		[contentView addSubview:_usageTermsLabel];
		[allControls addObject:_usageTermsLabel];
		[contactControls addObject:_usageTermsLabel];
		[loginControls addObject:_usageTermsLabel];
		
		/*
		[self loadCountries];
		//country
		_country = [[MHPopUpButton alloc] initWithFrame:CGRectMake(_contentWidth-20-250, 245, 200, 34)];
		var _countriesArray = [CPArray array];
		for (var i = 0; i < [countries count]; i++)
		{
			var obj = [countries objectAtIndex:i];
			for (var key in obj) {
    			if (obj.hasOwnProperty(key)) {
					[_countriesArray addObject:obj[key]];
    			}
			}
		}
		
		[_country addItemsWithTitles:_countriesArray];
		[_country setHidden:YES];
		[contentView addSubview:_country];
		[allControls addObject:_country];
		[contactControls addObject:_country];
		
		
		_countryLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Country:")];
		[_countryLabel setFrame:CGRectMake(5, 246, 126, 24)];
		[_countryLabel setFocusField:_email];
		[_countryLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_countryLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_countryLabel setHidden:YES];
		[contentView addSubview:_countryLabel];
		[allControls addObject:_countryLabel];
		[contactControls addObject:_countryLabel];
		*/
		
		
		//firstName
		_firstName = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"") width:200]
		[_firstName setFrame:CGRectMake(_contentWidth-20-250, 40, 200, 30)];
		[_firstName setEditable:YES]; 
		[_firstName setTarget:self]; 
		[_firstName setFont:[CPFont systemFontOfSize:14.0]];
		[_firstName setAction:@selector(textFieldDidEndEditing:)];
		[_firstName setDelegate:self];
		[_firstName setHidden:YES];
		[contentView addSubview:_firstName];
		[allControls addObject:_firstName];
		[contactControls addObject:_firstName];


		_firstNameLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Firstname:")];
		[_firstNameLabel setFrame:CGRectMake(5, 46, 126, 24)];
		[_firstNameLabel setFocusField:_email];
		[_firstNameLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_firstNameLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_firstNameLabel setHidden:YES];
		[contentView addSubview:_firstNameLabel];
		[allControls addObject:_firstNameLabel];
		[contactControls addObject:_firstNameLabel];

		//lastName
		_lastName = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"") width:200]
		[_lastName setFrame:CGRectMake(_contentWidth-20-250, 80, 200, 30)];
		[_lastName setEditable:YES]; 
		[_lastName setTarget:self]; 
		[_lastName setFont:[CPFont systemFontOfSize:14.0]];
		[_lastName setAction:@selector(textFieldDidEndEditing:)];
		[_lastName setDelegate:self];
		[_lastName setHidden:YES];
		[contentView addSubview:_lastName];
		[allControls addObject:_lastName];
		[contactControls addObject:_lastName];

		
		_lastNameLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Lastname:")];
		[_lastNameLabel setFrame:CGRectMake(5, 86, 126, 24)];
		[_lastNameLabel setFocusField:_email];
		[_lastNameLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_lastNameLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_lastNameLabel setHidden:YES];
		[contentView addSubview:_lastNameLabel];
		[allControls addObject:_lastNameLabel];
		[contactControls addObject:_lastNameLabel];

		_emailConfirm = [CPTextField textFieldWithStringValue:@"" placeholder:CPLocalizedString(@"") width:200]
		[_emailConfirm setFrame:CGRectMake(_contentWidth-20-250, 160, 200, 30)];
		[_emailConfirm setEditable:YES]; 
		[_emailConfirm setTarget:self]; 
		[_emailConfirm setFont:[CPFont systemFontOfSize:14.0]];
		[_emailConfirm setAction:@selector(textFieldDidEndEditing:)];
		[_emailConfirm setDelegate:self];
		[_emailConfirm setHidden:YES];
		[contentView addSubview:_emailConfirm];
		[allControls addObject:_emailConfirm];
		[contactControls addObject:_emailConfirm];


		_emailConfirmLabel = [CPFocusTextField labelWithTitle:CPLocalizedString(@"Confirm eMail:")];
		[_emailConfirmLabel setFrame:CGRectMake(5, 166,126, 24)];
		[_emailConfirmLabel setFocusField:_email];
		[_emailConfirmLabel setFont:[CPFont boldSystemFontOfSize:14.0]];
		[_emailConfirmLabel setValue:CPRightTextAlignment forThemeAttribute:@"alignment"];
		[_emailConfirmLabel setHidden:YES];
		[contentView addSubview:_emailConfirmLabel];
		[allControls addObject:_emailConfirmLabel];
		[contactControls addObject:_emailConfirmLabel];

		_cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(_contentWidth-85-85,170,80,24)];
		[_cancelButton setTitle:CPLocalizedString(@"Cancel")];
		[_cancelButton setTarget:self];
		[_cancelButton setAction:@selector(cancelLogin:)];
		[contentView addSubview:_cancelButton];
		[allControls addObject:_cancelButton];
		[loginControls addObject:_cancelButton];
		[lostControls addObject:_cancelButton];		
		[registerControls addObject:_cancelButton];
		[contactControls addObject:_cancelButton];		

		_okButton = [[CPButton alloc] initWithFrame:CGRectMake(_contentWidth-85,170,80,24)];
		[_okButton setTitle:CPLocalizedString(@"Login")];
		[_okButton setTarget:self];
		[_okButton setAction:@selector(doLogin:)];
		[contentView addSubview:_okButton];
		[allControls addObject:_okButton];
		[loginControls addObject:_okButton];
		[lostControls addObject:_okButton];		
		[registerControls addObject:_okButton];		
		[contactControls addObject:_okButton];		

		_registerButton = [[CPButton alloc] initWithFrame:CGRectMake(5,170,80,24)];
		[_registerButton setTitle:CPLocalizedString(@"Register")];
		[_registerButton setTarget:self];
		[_registerButton setAction:@selector(changeToRegistration:)];
		[contentView addSubview:_registerButton];
		[allControls addObject:_registerButton];
		[loginControls addObject:_registerButton];
		[lostControls addObject:_registerButton];
		[registerControls addObject:_registerButton];		
		[contactControls addObject:_registerButton];		

		_passwordTroubles = [[CPButton alloc] initWithFrame:CGRectMake(135,110,150,24)];
		[_passwordTroubles setTitle:CPLocalizedString(@"Password troubles?")];
		[_passwordTroubles setTarget:self];
		[_passwordTroubles setAction:@selector(changeToLostPassword:)];
		var image = [[CPImage alloc] initWithContentsOfFile:[[CPBundle mainBundle] pathForResource:@"redirect.png"] size:CPSizeMake(16, 16)];
		[_passwordTroubles setValue:CPLeftTextAlignment forThemeAttribute:@"alignment"];
		[_passwordTroubles setFont:[CPFont systemFontOfSize:14.0]];
		[_passwordTroubles setValue:CPImageRight forThemeAttribute:@"image-position"];
		[_passwordTroubles setImage:image];
		[_passwordTroubles setBordered:NO];
		[contentView addSubview:_passwordTroubles];
		[allControls addObject:_passwordTroubles];
		[loginControls addObject:_passwordTroubles];

		[theWindow orderFront:self];
		[theWindow setDefaultButton:_okButton];
		[theWindow setAcceptsMouseMovedEvents:YES];
		[theWindow setAutorecalculatesKeyViewLoop:NO];
		
		CPLog(@"The array"+allControls);
		
		[[self window] makeFirstResponder:_username];

	}
	return self;
}

- (void)setError:(int)error
{
	_error = error;
	CPLog(@"error = %d", error);
	[self layoutSubviews:YES];
}

-(void)hideShowControlsForArray:(CPArray) array
{	
	for (var i = 0; i < [allControls count]; i++) {
		var control = [allControls objectAtIndex:i];
		if (![array containsObject:control]){
			[control setHidden:YES];
		} else {
			[control setHidden:NO];
		}
	} 
}

- (void)layoutSubviews:(BOOL)checkForErrors
{
	if (!checkForErrors)
	{
		_error = LD_ERROR_NO_ERROR;
//		[_username setStringValue:@""];
	//	[_password setStringValue:@""];
//		[_passwordConfirmation setStringValue:@""];
//		[_email setStringValue:@""];
	}
	if (_loginMode == LM_LOGIN)
	{
		if (_initialY == 0) {
			_initialY = [[self window] frame].origin.y;
		}
		[[self window] setFrame:CGRectMake([[self window] frame].origin.x, _initialY, _contentWidth, 224) display:YES animate:YES];
		if (_error > 0) [_description setTextColor:_errorColor];
		switch (_error)
		{
			case LD_ERROR_NO_ERROR:
				[_description setTextColor:_textColor];
				[_description setStringValue:@"Enter your username and password to login."];
				break;
			case LD_ERROR_MISSING_USERNAME:
			case LD_ERROR_WRONG_USERNAME:
				[_description setStringValue:@"Please enter a valid username."];
				break;
			case LD_ERROR_MISSING_PASSWORD:
			case LD_ERROR_WRONG_PASSWORD:
				[_description setStringValue:@"Please enter a valid password."];
				break;
			case LD_ERROR_WRONG_USERNAME_OR_PASSWORD:
				[_description setStringValue:@"Please enter a valid username and password."];
				break;
			case LD_ERROR_USERNAME_EXISTS:
				[_description setStringValue:@"The username already exists."];
				break;
			default:
				break;
		}
		[_usernameLabel setTextColor:(_error == LD_ERROR_MISSING_USERNAME || _error == LD_ERROR_WRONG_USERNAME_OR_PASSWORD || _error == LD_ERROR_WRONG_USERNAME || _error == LD_ERROR_USERNAME_EXISTS) ? _errorColor : _textColor];
		[_passwordLabel setTextColor:(_error == LD_ERROR_MISSING_PASSWORD || _error == LD_ERROR_WRONG_USERNAME_OR_PASSWORD || _error == LD_ERROR_WRONG_PASSWORD) ? _errorColor : _textColor];

		[self hideShowControlsForArray:loginControls]
		[_usageTermsLabel setFrame:CGRectMake(135,170,150,24)];	
		[_usageTermsLabel setTitle:@"Usage Terms"];
		
		
		[_username setNextKeyView:_password];
		[_password setNextKeyView:_username];
		[_cancelButton setFrameOrigin:CGPointMake(_contentWidth-85-85,170)];
		[_okButton setFrameOrigin:CGPointMake(_contentWidth-85,170)];
		[_okButton setTitle:CPLocalizedString(@"Login")];
		[_registerButton setFrameOrigin:CGPointMake(5,170)];
		[_registerButton setTitle:CPLocalizedString(@"Register")];
		[_registerButton setAction:@selector(changeToRegistration:)];
		[[self window] setTitle:CPLocalizedString(@"Login")];
	}
	else if (_loginMode == LM_REGISTRATION)
	{
		if (_initialY == 0) {
			_initialY = [[self window] frame].origin.y;
		}
		[[self window] setFrame:CGRectMake([[self window] frame].origin.x, _initialY - (234-224)/2, _contentWidth, 234) display:YES animate:YES];
		if (_error > 0) {
			[_description setTextColor:_errorColor];	
		} else {
			[_description setTextColor:_textColor];	
		}
		switch (_error)
		{
			case LD_ERROR_NO_ERROR:
				[_description setTextColor:_textColor];
				[_description setStringValue:@"Username and Password:"];
				break;
			case LD_ERROR_MISSING_USERNAME:
			case LD_ERROR_WRONG_USERNAME:
				[_description setStringValue:@"Please enter a valid username."];
				break;
			case LD_ERROR_MISSING_PASSWORD:
			case LD_ERROR_WRONG_PASSWORD:
				[_description setStringValue:@"Please enter a valid password."];
				break;
			case LD_ERROR_MISSING_PASSWORD_CONFIRMATION:
				[_description setStringValue:@"Please enter a valid password confirmation."];
				break;
			case LD_ERROR_WRONG_PASSWORD_CONFIRMATION:
				[_description setStringValue:@"Wrong password confirmation."];
				break;
			case LD_ERROR_MISSING_EMAIL:
			case LD_ERROR_WRONG_EMAIL:
				[_description setStringValue:@"Please enter a valid email address."];
				break;
			case LD_ERROR_WRONG_USERNAME_OR_PASSWORD:
				[_description setStringValue:@"Please enter a valid username and password."];
				break;
			case LD_ERROR_REGISTRATION_FAILED:
				[_description setStringValue:@"An unknown error occurred during registration."];
				break;
			case LD_ERROR_MISSING_FIRSTNAME:
				[_description setStringValue:@"Please enter a firstname"];
				break;	
			case LD_ERROR_MISSING_LASTNAME:
				[_description setStringValue:@"Please enter a lastname"];
				break;	
			case LD_ERROR_MISSING_EMAIL_CONFIRMATION:
				[_description setStringValue:@"Please enter a valid email confirmation."];
				break;	
			case LD_ERROR_WRONG_EMAIL_CONFIRMATION:
				[_description setStringValue:@"Wrong email confirmation."];
				break;	
			default:
				break;
		}
		[_usernameLabel setTextColor:(_error == LD_ERROR_MISSING_USERNAME || _error == LD_ERROR_WRONG_USERNAME_OR_PASSWORD || _error == LD_ERROR_WRONG_USERNAME || _error == LD_ERROR_REGISTRATION_FAILED) ? _errorColor : _textColor];
		[_passwordLabel setTextColor:(_error == LD_ERROR_MISSING_PASSWORD || _error == LD_ERROR_WRONG_USERNAME_OR_PASSWORD || _error == LD_ERROR_WRONG_PASSWORD_CONFIRMATION|| _error == LD_ERROR_WRONG_PASSWORD || _error == LD_ERROR_REGISTRATION_FAILED) ? _errorColor : _textColor];
		[_passwordConfirmationLabel setTextColor:(_error == LD_ERROR_MISSING_PASSWORD_CONFIRMATION || _error == LD_ERROR_WRONG_PASSWORD_CONFIRMATION || _error == LD_ERROR_REGISTRATION_FAILED) ? _errorColor : _textColor];
		[_emailConfirmLabel setTextColor:(_error == LD_ERROR_WRONG_EMAIL_CONFIRMATION || _error == LD_ERROR_MISSING_EMAIL_CONFIRMATION) ? _errorColor : _textColor];
		[_emailLabel setTextColor:(_error == LD_ERROR_MISSING_EMAIL || _error == LD_ERROR_WRONG_EMAIL || _error == LD_ERROR_REGISTRATION_FAILED) ? _errorColor : _textColor];
		[_firstNameLabel setTextColor:(_error == LD_ERROR_MISSING_FIRSTNAME) ? _errorColor : _textColor];
		[_lastNameLabel setTextColor:(_error == LD_ERROR_MISSING_LASTNAME) ? _errorColor : _textColor];
		
		[_username setNextKeyView:_password];
		[_password setNextKeyView:_passwordConfirmation];
		[_passwordConfirmation setNextKeyView:_username];
		
		[self hideShowControlsForArray:registerControls];
	
		[_passwordConfirmation setFrameOrigin:CGPointMake(_contentWidth-20-250, 120)];
		[_passwordConfirmationLabel setFrameOrigin:CGPointMake(5, 126)];
		[_cancelButton setFrameOrigin:CGPointMake(_contentWidth-85-85,180)];
		[_cancelButton setTitle:CPLocalizedString(@"Cancel")];
		[_okButton setFrameOrigin:CGPointMake(_contentWidth-85,180)];
		[_okButton setTitle:CPLocalizedString(@"Next")];
		[_registerButton setFrameOrigin:CGPointMake(5,180)];
		[_registerButton setTitle:CPLocalizedString(@"Login")];
		[_registerButton setAction:@selector(changeToLogin:)];
		[[self window] setTitle:CPLocalizedString(@"Register - Step 1")];
	} 
	else if (_loginMode == LM_REGISTRATION_FINISH) { //step 2
		[[self window] setFrame:CGRectMake([[self window] frame].origin.x, _initialY - (404-224)/2, _contentWidth, 404) display:YES animate:YES];
		
		[_description setTextColor:_textColor];
		[_description setStringValue:@"Contact Info"];
		if (_error > 0) [_description setTextColor:_errorColor];
		
		switch (_error)
		{
			case LD_ERROR_NO_ERROR:
				[_description setTextColor:_textColor];
				[_description setStringValue:@"Contact Info:"];
				break;
			case LD_ERROR_MISSING_EMAIL:
			case LD_ERROR_WRONG_EMAIL:
				[_description setStringValue:@"Please enter a valid email address."];
				break;
			case LD_ERROR_REGISTRATION_FAILED:
				[_description setStringValue:@"An unknown error occurred during registration."];
				break;
			case LD_ERROR_MISSING_FIRSTNAME:
				[_description setStringValue:@"Please enter a firstname"];
				break;	
			case LD_ERROR_MISSING_LASTNAME:
				[_description setStringValue:@"Please enter a lastname"];
				break;	
			case LD_ERROR_MISSING_EMAIL_CONFIRMATION:
				[_description setStringValue:@"Please enter a valid email confirmation."];
				break;	
			case LD_ERROR_WRONG_EMAIL_CONFIRMATION:
				[_description setStringValue:@"Wrong email confirmation."];
				break;	
			case LD_ERROR_MISSING_ORGANIZATION:
				[_description setStringValue:@"Please enter an organization"];
				break;
			case LD_ERROR_MISSING_PHONE:
				[_description setStringValue:@"Please enter a phone number"];
				break;
			case LD_ERROR_MISSING_SECURITYRESULT:
				[_description setStringValue:@"Please answer the security question"];
				break;
			case LD_ERROR_WRONG_SECURITYRESULT:
				[_description setStringValue:@"Security question not answered correctly"];
				break;
			case LD_ERROR_LICENSE_AGREEMENT:
				[_description setStringValue:@"Please accept the usage terms"];
				break;
			default:
				break;
		}
		
		[_email setFrameOrigin:CGPointMake(_contentWidth-20-250, 120)];
		[_emailLabel setFrameOrigin:CGPointMake(5, 126)];
		[_emailConfirm setFrameOrigin:CGPointMake(_contentWidth-20-250, 160)];
		[_emailConfirmLabel setFrameOrigin:CGPointMake(5, 166)];

		[_usageTerms setFrameOrigin:CGPointMake(115, 320)];
		[_usageTermsLabel setFrame:CGRectMake(_contentWidth-20-240, 314, 200, 30)];	
		[_usageTermsLabel setTitle:@"Accept Usage Terms"];
		
		[_firstName setNextKeyView:_lastName];
		[_lastName setNextKeyView:_email];
		[_email setNextKeyView:_emailConfirm];
		[_emailConfirm setNextKeyView:_organization];
		[_organization setNextKeyView:_phone];
		[_phone setNextKeyView:_securityResult];
		[_securityResult setNextKeyView:_firstName];
		
		[self hideShowControlsForArray:contactControls]
		
		[_cancelButton setFrameOrigin:CGPointMake(_contentWidth-85-85,350)];
		[_cancelButton setTitle:CPLocalizedString(@"Back")];
		[_okButton setFrameOrigin:CGPointMake(_contentWidth-85,350)];
		[_okButton setTitle:CPLocalizedString(@"Finish")];
		[_registerButton setFrameOrigin:CGPointMake(5,350)];
		[_registerButton setTitle:CPLocalizedString(@"Login")];
		[_registerButton setAction:@selector(changeToLogin:)];
		[[self window] setTitle:CPLocalizedString(@"Register - Step 2")];
	}
	else if (_loginMode == LM_LOSTPASSWORD)
	{
		if (_initialY == 0) {
			_initialY = [[self window] frame].origin.y;
		}
		[[self window] setFrame:CGRectMake([[self window] frame].origin.x, _initialY, _contentWidth, 224) display:YES animate:YES];
		if (_error > 0) [_description setTextColor:_errorColor];
		switch (_error)
		{
			case LD_ERROR_NO_ERROR:
				[_description setTextColor:_textColor];
				[_description setStringValue:@"Lost your password?"];
				break;
			case LD_ERROR_LOSTPASSWORD_FAILED:
				[_description setStringValue:@"The requested email address is not registered."];
				break;
			case LD_ERROR_MISSING_EMAIL:
			case LD_ERROR_WRONG_EMAIL:
				[_description setStringValue:@"Please enter a valid email address."];
				break;
			default:
				break;
		}
		[_passwordConfirmationLabel setTextColor:(_error == LD_ERROR_MISSING_PASSWORD_CONFIRMATION || _error == LD_ERROR_WRONG_PASSWORD_CONFIRMATION || _error == LD_ERROR_REGISTRATION_FAILED) ? _errorColor : _textColor];

		[self hideShowControlsForArray:lostControls]
		[_lostPasswordDescription setFrameOrigin:CGPointMake(5,40)];
		[_email setFrameOrigin:CGPointMake(_contentWidth-20-250, 120)];
		[_emailLabel setFrameOrigin:CGPointMake(5, 126)];
		[_cancelButton setFrameOrigin:CGPointMake(_contentWidth-85-85,170)];
		[_okButton setFrameOrigin:CGPointMake(_contentWidth-85,170)];
		[_okButton setTitle:CPLocalizedString(@"Request")];
		[_registerButton setFrameOrigin:CGPointMake(5,170)];
		[_registerButton setTitle:CPLocalizedString(@"Login")];
		[_registerButton setAction:@selector(changeToLogin:)];
		[[self window] setTitle:CPLocalizedString(@"Password troubles?")];
	}
}

- (void)controlTextDidChange:(CPNotification)aNotification
{
}

- (void)textFieldDidEndEditing:(CPNotification)aNotification
{
	[self doLogin:nil];
}

- (void)cancelLogin:(id)sender
{
	if (_loginMode == LM_REGISTRATION_FINISH) {
		_loginMode =  LM_REGISTRATION;
		[self layoutSubviews:YES];
	} else {
		[[CPApplication sharedApplication] abortModal];
		[[self window] close]; 
	}	
}

- (void)doLogin:(id)sender
{
	if (_loginMode == LM_LOGIN)
	{
		var username = [_username stringValue];
		var password = [_password stringValue];
		if ([username length] && [password length])
		{
			if (_delegate && [_delegate respondsToSelector:@selector(loginDialog:didCallLoginWithUsername:andPassword:)])
			{
				[_delegate loginDialog:self didCallLoginWithUsername:username andPassword:password];
			}
		}
		else
		{
			if ([password length] == 0) _error = LD_ERROR_MISSING_PASSWORD;
			if ([username length] == 0) _error = LD_ERROR_MISSING_USERNAME;
			[self layoutSubviews:YES];
		}
	}
	else if (_loginMode == LM_REGISTRATION)  //Step 1 Registration
	{
		var username = [_username stringValue];
		var password = [_password stringValue];
		var passwordConfirmation = [_passwordConfirmation stringValue];
			if ([username length] > 2 && [password length] > 5 && [passwordConfirmation length])
		{
			if (![password isEqualToString:passwordConfirmation])
			{
				_error = LD_ERROR_WRONG_PASSWORD_CONFIRMATION;
				[self layoutSubviews:YES];
			}
			/*
			if (![email isEqualToString:emailConfirmation]) {
				_error = LD_ERROR_WRONG_EMAIL_CONFIRMATION;
				[self layoutSubviews:YES];
			}
			
			else if (!filter.test(email))
			{
				_error = LD_ERROR_WRONG_EMAIL;
				[self layoutSubviews:YES];
			}
			*/
			else
			{
				//change to STEP 2
				_usernameConfirmed = username;
				_passwordConfirmed = password;
				_loginMode = LM_REGISTRATION_FINISH;
				[[self window] makeFirstResponder:_firstName];
				[self layoutSubviews:NO];

				/*
				if (_delegate && [_delegate respondsToSelector:@selector(loginDialog:didCallRegistrationWithUsername:firstname:lastname:password:andEmail:)])
				{
					[_delegate loginDialog:self didCallRegistrationWithUsername:username firstname:firstname lastname:lastname password:password andEmail:email];
				}
				*/
			}
		}
		else
		{
			if ([passwordConfirmation length] == 0) _error = LD_ERROR_MISSING_PASSWORD_CONFIRMATION;
			if ([password length] == 0) _error = LD_ERROR_MISSING_PASSWORD;
			if ([username length] == 0) _error = LD_ERROR_MISSING_USERNAME;
			if ([password length] < 6) _error = LD_ERROR_WRONG_PASSWORD;
			if ([username length] < 3) _error = LD_ERROR_WRONG_USERNAME;
			[self layoutSubviews:YES];
		}
	}
	else if (_loginMode == LM_REGISTRATION_FINISH)  //Step 2 Registration
	{
		var username = [_username stringValue];
		var password = [_password stringValue];
		var firstname = [_firstName stringValue];
		var lastname = [_lastName stringValue];
		var email = [_email stringValue];
		var emailConfirmation = [_emailConfirm stringValue];
		var organization = [_organization stringValue];
		var phone = [_phone stringValue];
		var securityResult = [_securityResult stringValue];
		var usageTerms = [_usageTerms state];
		var filter = new RegExp("^[-a-zA-Z0-9+._]+@[-a-zA-Z0-9.]+\\.[a-zA-Z]{2,6}$");
		
		if ([firstname length] && [lastname length] && [email length] && [emailConfirmation length] && [organization length] && [phone length] && [securityResult length]
			&& usageTerms == CPOnState ) 
		{
			if (![email isEqualToString:emailConfirmation]) {
				_error = LD_ERROR_WRONG_EMAIL_CONFIRMATION;
				[self layoutSubviews:YES];
			}
			
			else if (!filter.test(email))
			{
				_error = LD_ERROR_WRONG_EMAIL;
				[self layoutSubviews:YES];
			} else if (securityResult!=securityResultNum)
			{
				_error = LD_ERROR_WRONG_SECURITYRESULT;
				[self layoutSubviews:YES];
			}
			else { //process registration
				if (_delegate && [_delegate respondsToSelector:@selector(loginDialog:didCallRegistrationWithUsername:firstname:lastname:password:organization:phone:andEmail:)])
				{
					CPLog(@"Username %@"+_usernameConfirmed);
					CPLog(@"Password %@"+_passwordConfirmed);

					[_delegate loginDialog:self didCallRegistrationWithUsername:_usernameConfirmed firstname:firstname lastname:lastname password:_passwordConfirmed organization:organization phone:phone andEmail:email];
				}
			}
		} else {
			if (usageTerms == CPOffState) _error = LD_ERROR_LICENSE_AGREEMENT;
			if ([firstname length] == 0) _error = LD_ERROR_MISSING_FIRSTNAME;
			if ([lastname length] == 0) _error = LD_ERROR_MISSING_LASTNAME;
			if ([email length] == 0) _error = LD_ERROR_MISSING_EMAIL;
			if ([emailConfirmation length] == 0) _error = LD_ERROR_MISSING_EMAIL_CONFIRMATION;
			if ([organization length] == 0) _error = LD_ERROR_MISSING_ORGANIZATION;
			if ([phone length] == 0) _error = LD_ERROR_MISSING_PHONE;
			if ([securityResult length] == 0) _error = LD_ERROR_MISSING_SECURITYRESULT;
			CPLog(@"Calling layout again %i",_error)
			[self layoutSubviews:YES];
		}
		
	}
	else if (_loginMode == LM_LOSTPASSWORD)
	{
		var email = [_email stringValue];
		if ([email length])
		{
			if (_delegate && [_delegate respondsToSelector:@selector(loginDialog:didCallLostPassword:)])
			{
				[_delegate loginDialog:self didCallLostPassword:email];
			}
		}
		else
		{
			if ([email length] == 0) _error = LD_ERROR_MISSING_EMAIL;
			[self layoutSubviews:YES];
		}
	}
}

- (void)changeToRegistration:(id)sender
{
	_loginMode = LM_REGISTRATION;
	[[self window] makeFirstResponder:_username];
	[self layoutSubviews:NO];
}

- (void)changeToLogin:(id)sender
{
	_loginMode = LM_LOGIN;
	[[self window] makeFirstResponder:_username];
	[self layoutSubviews:NO];
}

- (void)changeToLostPassword:(id)sender
{
	_loginMode = LM_LOSTPASSWORD;
	[[self window] makeFirstResponder:_email];
	[self layoutSubviews:NO];
}

- (void)closeDialog
{
	[[CPApplication sharedApplication] abortModal];
	[[self window] close]; 
}

-(BOOL)windowShouldClose:(id)window
{
	[self cancelLogin:self];
	return true;
}

@end