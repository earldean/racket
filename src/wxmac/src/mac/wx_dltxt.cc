///////////////////////////////////////////////////////////////////////////////
// File:	wx_dltxt.cc
// Purpose:	wxDialogText (Macintosh version)
// Author:	Bill Hale
// Created:	1994
// Updated:	
// Copyright:  (c) 1993-94, AIAI, University of Edinburgh. All Rights Reserved.
///////////////////////////////////////////////////////////////////////////////

static const char sccsid[] = "%W% %G%";

#include "wx_dialg.h"
#include "wx_frame.h"
#include "wx_panel.h"
#include "wx_gdi.h"
#include "wx_buttn.h"
#include "wx_types.h"
#include "wx_utils.h"
#include "wx_txt.h"

static void wxOkButtonProc(wxButton& button, wxEvent& event);
static void wxCancelButtonProc(wxButton& button, wxEvent& event);

char* wxGetTextFromUser(char* message, char* caption = "Input text",
				char* default_value = "", wxFrame* parent = NULL,
				int x = -1, int y = -1, Bool centre = TRUE);

//-----------------------------------------------------------------------------
// Pop up a dialog text box
//-----------------------------------------------------------------------------
char* wxGetTextFromUser(char* message, char* caption, char* default_value,
                 wxFrame* parent, int x, int y, Bool centre)
{
	wxDialogBox* dialog = new wxDialogBox((wxFrame*)NULL, caption, TRUE, x, y);

//============================================
	wxPanel* dialogPanel = new wxPanel(dialog);
	wxFont* theFont = new wxFont(12, wxROMAN, wxITALIC, wxBOLD);
	dialogPanel->SetLabelFont(theFont);
	dialogPanel->SetButtonFont(theFont);

//============================================
	wxPanel* messagePanel = new wxPanel(dialogPanel, -1, -1, -1, -1);

	wxList messageList;
	wxSplitMessage(message, &messageList, messagePanel);
	messagePanel->Fit();
	if (centre)
	{
		wxCentreMessage(&messageList);
	}
	//dialogPanel->AdvanceCursor(messagePanel); // WCH: kludge

//============================================
	dialogPanel->NewLine();
	wxText* textBox = new wxText(dialogPanel, NULL, NULL, default_value,
						-1, -1, 100, 20, wxBORDER); // WCH: must fix explict width & height
	textBox->Highlight(0, textBox->GetLastPosition());
	textBox->SetFocus();

//============================================
	dialogPanel->NewLine();
	wxPanel* buttonPanel = new wxPanel(dialogPanel, -1, -1, -1, -1);

	wxButton* ok = NULL;
	wxButton* cancel = NULL;
	wxButton* yes = NULL;
	wxButton* no = NULL;

	ok = new wxButton(buttonPanel, (wxFunction)&wxOkButtonProc, "OK");
	cancel = new wxButton(buttonPanel, (wxFunction)&wxCancelButtonProc, "Cancel");
	ok->SetDefault();

	buttonPanel->Fit();
	//dialogPanel->AdvanceCursor(messagePanel); // WCH: kludge

//============================================
	
	dialogPanel->Fit();
	dialog->Fit();

	messagePanel->Centre(wxHORIZONTAL);
	buttonPanel->Centre(wxHORIZONTAL);

	dialogPanel->Centre(wxBOTH);

//============================================
	
	dialog->ShowModal();
	int buttonPressed = dialog->GetButtonPressed();
	char* result = (buttonPressed == wxOK ? textBox->GetValue() : NULL);
	delete dialog;

//============================================

	return result;
}

//=============================================================================
//
// Dialog button callback procedures
//
//=============================================================================

//-----------------------------------------------------------------------------
static void wxOkButtonProc(wxButton& button, wxEvent& event)
{
	wxDialogBox* dialog = (wxDialogBox*) button.GetRootFrame();

	dialog->SetButtonPressed(wxOK);
	dialog->Show(FALSE);
}

//-----------------------------------------------------------------------------
static void wxCancelButtonProc(wxButton& button, wxEvent& event)
{
	wxDialogBox* dialog = (wxDialogBox*) button.GetRootFrame();

	dialog->SetButtonPressed(wxCANCEL);
	dialog->Show(FALSE);
}