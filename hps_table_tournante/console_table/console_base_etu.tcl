#!/sw/bin/wish
# ----------------------------------------------------------------------------------------
# -- HEIG-VD /////////////////////////////////////////////////////////////////////////////
# -- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
# -- School of Business and Engineering in Canton de Vaud
# ----------------------------------------------------------------------------------------
# -- REDS Institute //////////////////////////////////////////////////////////////////////
# -- Reconfigurable Embedded Digital Systems
# ----------------------------------------------------------------------------------------
# --
# -- File                 : console_base_etu.tcl
# -- Author               : Florent Duployer & Evangelina Lolivier-Exler	
# -- Last modification	  : 15.12.2014
# --
# -- Context              : Laboratoires de numerique
# --
# ----------------------------------------------------------------------------------------
# -- Description :
# -- Console d'interface avec la carte Servo_USB
# -- Important: cette console ne marche qu'en mode target, pas en mode simulation
# ----------------------------------------------------------------------------------------
# modification:
#  1.0 08.01.2015   adaptation pour linux !!!!!
#      15.01.2015   affichage, mettre l avertissement au premier plan
#      03.02.2015   affichage, renomer stdby en stby_ON stby_OFF
# ----------------------------------------------------------------------------------------
# Set global variables
set usbMajor "08ee"
set usbMinor "4004"

package require Tk
# Set global variables
set consoleInfo(version) 1.0
set consoleInfo(title) "Servo USB - base_etu"; # Title that will be display in title bar
set consoleInfo(filename) "console_base_etu"; # Filename without the filetype

# 
set redsToolsPath /opt/tools_reds 
set usbInstallDir "/opt/tools_reds/lib/usb2"
set Env linux
set debugMode FALSE; # Display debug info
set sigImgFile "./REDS_console_sigImg.gif"


# Load resources
if { [catch {source $redsToolsPath/TCL_TK/Graphical_Elements.tcl} msg1] } {
  puts "Set path for Windows environment"
  set redsToolsPath c:/EDA/tools_reds
  set Env windows
  if { [catch {source $redsToolsPath/TCL_TK/Graphical_Elements.tcl} msg2] } {   
    puts "Cannot load Graphical Elements!"
    }
}

source $redsToolsPath/TCL_TK/StdProc.tcl


# ----------------------------------------------------------------------------------------
# -- Fonctions de gestion de la console //////////////////////////////////////////////////
# ----------------------------------------------------------------------------------------

# --| SETVARIABLES |----------------------------------------------------------------------
# --  Set fonts and addresses
# ----------------------------------------------------------------------------------------
proc SetVariables {} {
  # Global variables, see below
  global fnt speed runningMode \
         dataPin adrConfPin adrDataPin \
         adrVersion adrSUBD25OE adrResetConf \
         strResourcePath images windowOpen \
		 adr80polesOE adrResetData nbrPas

  # Redirect StdOut to nowhere (prevent polution in logs)
  StdOut off

  # Fonts
  font create fnt{3} -family {MS Sans Serif} -weight bold -size 8; puts ""
  font create fnt{4} -family {MS Sans Serif} -weight normal -size 8; puts ""
  font create fnt{5} -family {Courier New} -weight normal -size 8; puts ""

  # Speeds
  if {$runningMode == "Simulation"} {
    set speed(Refresh) 1; 
  } else {
    set speed(Refresh) 1; # Time [ms] between run steps (target mode)
  }

  # Addresses to configure pins of the SUB25s of the board
  set adrConfPin(D01_08) [format %d 0x4000]; # Right connector, pins 1  to 8
  set adrConfPin(D09_16) [format %d 0x4001]; # Right connector, pins 9  to 16
  set adrConfPin(D17_24) [format %d 0x4002]; # Right connector, pins 17 to 24
  set adrConfPin(D25_27) [format %d 0x4003]; # Right connector, pins 25 to 27
  set adrConfPin(G01_08) [format %d 0x4004]; # Left connector,  pins 1  to 8
  set adrConfPin(G09_16) [format %d 0x4005]; # Left connector,  pins 9  to 16
  set adrConfPin(G17_24) [format %d 0x4006]; # Left connector,  pins 17 to 24
  set adrConfPin(G25_27) [format %d 0x4007]; # Left connector,  pins 25 to 27

  # Addresses to set the value of pins of the SUB25s of the board
  set adrDataPin(D01_08) [format %d 0x5000]; # Right connector, pins 1  to 8
  set adrDataPin(D09_16) [format %d 0x5001]; # Right connector, pins 9  to 16
  set adrDataPin(D17_24) [format %d 0x5002]; # Right connector, pins 17 to 24
  set adrDataPin(D25_27) [format %d 0x5003]; # Right connector, pins 25 to 27
  set adrDataPin(G01_08) [format %d 0x5004]; # Left connector,  pins 1  to 8
  set adrDataPin(G09_16) [format %d 0x5005]; # Left connector,  pins 9  to 16
  set adrDataPin(G17_24) [format %d 0x5006]; # Left connector,  pins 17 to 24
  set adrDataPin(G25_27) [format %d 0x5007]; # Left connector,  pins 25 to 27
  
   # Addresses to configure pins of the Eighty Poles of the board
  set adrConfPin(E01_08) [format %d 0x4008]; 
  set adrConfPin(E09_16) [format %d 0x4009]; 
  set adrConfPin(E17_24) [format %d 0x400A]; 
  set adrConfPin(E25_32) [format %d 0x400B]; 
  set adrConfPin(E33_40) [format %d 0x400C]; 
  set adrConfPin(E41_48) [format %d 0x400D]; 
  set adrConfPin(E49_56) [format %d 0x400E]; 
  set adrConfPin(E57_64) [format %d 0x400F]; 
  set adrConfPin(E65_72) [format %d 0x4010]; 
  set adrConfPin(E73_80) [format %d 0x4011]; 

  # Addresses to set the value of pins of the Eighty Poles of the board
  set adrDataPin(E01_08) 		[format %d 0x5008]; 
  set adrDataPin(E09_16) 		[format %d 0x5009]; 
  set adrDataPin(E17_24) 		[format %d 0x500A]; 
  set adrDataPin(E25_32) 		[format %d 0x500B]; 
  set adrDataPin(E33_40) 		[format %d 0x500C]; 
  set adrDataPin(E41_48) 		[format %d 0x500D]; 
  set adrDataPin(E49_56) 		[format %d 0x500E]; 
  set adrDataPin(E57_64) 		[format %d 0x500F]; 
  set adrDataPin(E65_72) 		[format %d 0x5010]; 
  set adrDataPin(E73_80) 		[format %d 0x5011]; 
 
  # Addresse of the Switchs
  set adrDataPin(S01_05) [format %d 0x5100]; # SW 1 to 5
  
    # Addresses to set the values of the LEDs
  set adrDataPin(L01_08) 		[format %d 0x5101]; # LED 1 to 8
  set adrDataPin(L09_16) 		[format %d 0x5102]; # LED 9 to 16
  set adrDataPin(L17_24) 		[format %d 0x5103]; # LED 17 to 24
  
  # Addresses to manage general values of the motors
  set adrDataPin(En)			[format %d 0x5104]; # general Enable of the motor
  set adrDataPin(Courant) 		[format %d 0x5105]; # Adresse which contains the current or voltage (on one byte) that we want to put in the motor
  
  # Addresses to set the values of the stepper
  set adrDataPin(A_nB) 	 		[format %d 0x5106]; # Not used! Voltage is to be written on B or A. (1 for A, 0 for B)
  set adrDataPin(CS_WR)  		[format %d 0x5107]; # Not used! Write the voltage on B or A
  set adrDataPin(Clr) 			[format %d 0x5108]; # Not used! Adresse to clear the voltage set
  set adrDataPin(StepEn) 		[format %d 0x5109]; # Stepper driver enable
  set adrDataPin(Wr_BA)			[format %d 0x510A]; # Not used! Write on A and/or B (First bit => A, Second Bit => B)
  set adrDataPin(CCW_nCW) 		[format %d 0x510B]; # CW or CCW 
  set adrDataPin(DelayWR)		[format %d 0x510C]; # Strobe for load of the delay value
  set adrDataPin(Delay)			[format %d 0x510D]; # Delay (On 8 bits)
  set adrDataPin(CurWR)			[format %d 0x510E]; # Strobe for load the current value
  set adrDataPin(Error)			[format %d 0x510F]; # Error (only read)
   
  
  # Addresses to set the values of the DC motor
  set adrDataPin(Mode)			[format %d 0x5110]; # Mode, PWM or OSC (1 for PWM)
  set adrDataPin(Duty)			[format %d 0x5111]; # Duty cycle of the PWM (On 1 byte)
  set adrDataPin(RunMode)		[format %d 0x5112]; # Mode selection, on 3 Bits(IN1, IN2, SB). Choice among Stop,CW, CCW, Short brake or StandBy
  set adrDataPin(WR_Vref)		[format %d 0x5113]; # Strobe for load of the voltage value. (OSC mode)
  set adrDataPin(WR_Duty)		[format %d 0x5114]; # Strobe for load of the duty cycle value. (PWM mode)
  set adrDataPin(Alert_dc)		[format %d 0x5115]; # Alert (only read)
  
  # Addresses to read the encoder data
  set adrDataPin(EncRefSense)		[format %d 0x5116]; # Rotation sense (ref): bit0 -> clockwise, bit1 -> counterclockwise 
  set adrDataPin(EncRevRefHi)		[format %d 0x5117]; # Whole revolutions counter MSB (ref)
  set adrDataPin(EncRevRefLo)		[format %d 0x5118]; # Whole revolutions counter LSB (ref)
  set adrDataPin(EncPulseRefHi) 	[format %d 0x5119]; # Pulses counter MSB Ref
  set adrDataPin(EncPulseRefLo) 	[format %d 0x511A]; # Pulses counter LSB Ref
  set adrDataPin(EncCapt)     		[format %d 0x511B]; # Capteur disque
  set adrDataPin(EncPulseEtuHi) 	[format %d 0x511C]; # Pulses counter MSB Etu
  set adrDataPin(EncPulseEtuLo) 	[format %d 0x511D]; # Pulses counter LSB Etu
  set adrDataPin(EncIndexRefHi) 	[format %d 0x511E]; # Index counter MSB (ref)
  set adrDataPin(EncIndexRefLo) 	[format %d 0x511F]; # Index counter LSB (ref)
  set adrDataPin(EncRevEtuHi)		[format %d 0x5120]; # Whole revolutions counter MSB Etu
  set adrDataPin(EncRevEtuLo)		[format %d 0x5121]; # Whole revolutions counter LSB Etu
  set adrDataPin(EncIndexEtuHi) 	[format %d 0x5122]; # Index counter MSB Etu
  set adrDataPin(EncIndexEtuLo) 	[format %d 0x5123]; # Index counter LSB Etu
  set adrDataPin(EncEtuSense)		[format %d 0x5124]; # Rotation sense (etu): bit0 -> clockwise, bit1 -> counterclockwise
  set adrDataPin(EncRefErr)			[format %d 0x5125]; # Detection Error (ref)
  set adrDataPin(EncEtuErr)			[format %d 0x5126]; # Detection Error (etu)
  
  set adrDataPin(EncResetCnt) 		[format %d 0x5127]; # Counters reset
  
  
  # Addresses to switch between Reference mode or Student mode
  
  set adrDataPin(PapModeEtu)		[format %d 0x5128]; # When 1, students design on third board controls the PAP motor
  set adrDataPin(DcModeEtu)  		[format %d 0x5129]; # When 1, students design on third board controls the DC motor
  
  set nbrPas 0
  
  # Address for the version of the FPGA
  set adrVersion [format %d 0x6000]

  # Address to activate the IOs of the SUBD25 pins
  set adrSUBD25OE [format %d 0x4ffc]
  
  # Address to activate the IOs of the 80 poles pins
  set adr80polesOE [format %d 0x4ffd]
  
  # Address to reset the datas of the board
  set adrResetData [format %d 0x4ffe]
  
  # Address to reset the IOs of the board
  set adrResetConf [format %d 0x4fff]

  # Data variables for inputs/outputs
  set dataPin(D01_08) 0; # Val_A
  set dataPin(D09_16) 0; # Val_B
  set dataPin(D17_24) 0; # Switches
  set dataPin(D25_27) 0; # N/A
  set dataPin(G01_08) 0; # Result_A
  set dataPin(G09_16) 0; # Result_B
  set dataPin(G17_24) 0; # Leds
  set dataPin(G25_27) 0; # N/A
  
  set dataPin(S01_05) 0; # Switches of the servo usb

  # Images
  #set images(labels) [image create photo -file "$strResourcePath/img/REDS_console_labels.gif"]; puts ""

  # To check if windows are open
  set windowOpen(SignalLabels) FALSE
  set windowOpen(About) FALSE
	
  # Reactivate StdOut
  StdOut on
}


# --| CLOSECONSOLE |----------------------------------------------------------------------
# --  Prepare la fermeture de la console en detruisant certains des objets crees. Ceci
# --  permet la reouverture de la console, mais evite egalement la polution de la memoire
# --  en detruisant les objets inutilises.
# --  Cette procedure est appelee a la fermeture de la fenetre ainsi que par la
# --  procedure "QuitConsole{}".
# ----------------------------------------------------------------------------------------
proc CloseConsole {} {
  global fnt runningMode adrResetConf adrConfPin runText

  # Stop simulation if it is running
  if {$runText == "Stop"} {
    set runText Run
  }

  # Destruction des objets du top
  foreach w [winfo children .top] {
    destroy $w
  }

  # Desctruction du top
  destroy .top

  # Suppression des polices
  font delete fnt{3}
  font delete fnt{4}
  font delete fnt{5}

  if {$runningMode == "Simulation"} {
    # Delete all signal on wave view
    #delete wave *

  } else {
    # Reset the line driver OE of the board
    EcrireUSB $adrResetConf 0

    # Set all pins of both SUB25 as Inputs
    foreach element [array names adrConfPin] {
      EcrireUSB $adrConfPin($element) [format %d 0x00]
    }

    # Exit application
    exit
  }

  # Free variable
  unset runText
  unset runningMode
}


# --| QuitConsole |-----------------------------------------------------------------------
# --  Appel la fonction de fermeture de la console, puis quitte.
# ----------------------------------------------------------------------------------------
proc QuitConsole {} {
  CloseConsole; # Clean before closing
  exit
}


# --| CHECKRUNNINGMODE |-------------------------------------------------------------------------
# --  Check if the console was started from simulation (Simulation running mode) or
# --  in standalone (Target running mode).
# ----------------------------------------------------------------------------------------
proc CheckRunningMode {} {
  # Global variables:
  #   - Path to the resources
  #   - Current running mode
  global strResourcePath runningMode usbInstallDir redsToolsPath consoleInfo usbMajor usbMinor Env

  # Directory where the USB2 drivers are installed
  # Directory where the USB2 drivers are installed
  set InstallDir "$redsToolsPath/lib/usb2/"
  if {$Env == "linux" } {
    set libName "libredsusb.so"
  } else {
    set libName "GestionUSB2.dll"
  }

  # No error by default
  set isErr 0

  # Check for standalone run (meaning it has not been launched from QuestaSim)
  if {[wm title .] == $consoleInfo(filename)} {
    wm withdraw .
  }
 
  # Check the running mode -> Simulation or Target
  catch {restart -f} err1
  if {$err1 != "invalid command name \"restart\""} {
    set runningMode "Simulation"
  } else {
    set runningMode "Target"
    set strResourcePath "."
    # Test if the DLL "GestionUSB2" is installed
    catch {load $InstallDir$libName} err2
    if {$err2 != "" } {
      # Error --> try in local folder
      catch {load $libName} err3
      if {$err3 != "" } {
        # Installation error
        set msgErr "GestionUSB2.dll n'est pas install\E9e correctement"
        set isErr  1
      } else {
        set usbInstallDir .
      }
    }

  }

  #set message [info script]
  #tk_messageBox -icon info -type ok -title Info -message $message
  #set message [info nameofexecutable]
  #tk_messageBox -icon info -type ok -title Info -message $message

  # Display error message if necessary
  if {$isErr == 1} {
      tk_messageBox -icon error -type ok -title Erreur -message $msgErr
      exit; # Quit the script
  }
  catch {UsbSetDevice "$usbMajor" "$usbMinor"} err
}


# --| CREATEMAINWINDOW |------------------------------------------------------------------
# --  Creation de la fenetre principale comprenand:
# --	- Les panneaux de contr\F4les des moteurs
# -- 	- Les entr\E9es/sorties du SUBD25, port80, ainsi que LEDs et Switchs du PCB
# ----------------------------------------------------------------------------------------
proc CreateMainWindow {} {
  global consoleInfo fnt{3} runningMode images debugLabel runText
  global continuMode sigImgFile

  # creation de la fenetre principale
  toplevel .top -class toplevel

  # Call "CloseConsole" when Top is closed
  wm protocol .top WM_DELETE_WINDOW CloseConsole

  set Win_Width  850
  set Win_Height 730

  set x0 200
  set y0 100

  wm geometry .top $Win_Width\x$Win_Height+$x0+$y0

  wm resizable  .top 0 0
  wm attributes .top -topmost 1
  wm title .top "$consoleInfo(title) $consoleInfo(version) - $runningMode mode"

  # Creation des 'frame' entree et sortie
  canvas .top.main
  place .top.main -x 0 -y 0 -height $Win_Height -width $Win_Width

  # Cr\E9ation d'une frame pour les I/O Moteur
  frame .top.main.moteurFrame -borderwidth 2 -relief groove
  place .top.main.moteurFrame -x 5 -y 150 -height 530 -width 840
  
  message 	.top.main.moteurFrame.info -text "Controle des moteurs" -font fnt{3} -aspect 800 -borderwidth 1 -relief solid
  place 	.top.main.moteurFrame.info -x 0 -y 0 -relwidth 1
  
  # cr\E9ation d'une frame pour la gestion du moteur DC
  frame .top.main.moteurFrame.dc -borderwidth 2 -relief groove
  place .top.main.moteurFrame.dc -x 0 -y 20 -height 270 -width 530
  
  message 	.top.main.moteurFrame.dc.info -text "MoteurDC" -font fnt{3} -aspect 1000 -borderwidth 1 -relief solid
  place 	.top.main.moteurFrame.dc.info -x 0 -y 0 -relwidth 1
  
  message 	.top.main.moteurFrame.dc.osc -text "OSC:Courant" -font fnt{4} -aspect 300
  place 	.top.main.moteurFrame.dc.osc -x 50 -y 130 -relwidth 0.2
  message 	.top.main.moteurFrame.dc.pwm -text "PWM:Rapport Cyclique" -font fnt{4} -aspect 600
  place 	.top.main.moteurFrame.dc.pwm -x 230 -y 130 -relwidth 0.5
  
  # cr\E9ation d'une frame pour l'affichage des informations des encodeurs
  frame .top.main.moteurFrame.encoder -borderwidth 2 -relief groove
  place .top.main.moteurFrame.encoder -x 0 -y 295 -height 230 -width 835
  
  frame .top.main.moteurFrame.encoder.ref -borderwidth 2 -relief groove
  place .top.main.moteurFrame.encoder.ref -x 110 -y 20 -height 100 -width 720
  
  frame .top.main.moteurFrame.encoder.etu -borderwidth 2 -relief groove
  place .top.main.moteurFrame.encoder.etu -x 110 -y 120 -height 100 -width 720
  
  message 	.top.main.moteurFrame.encoder.info -text "Encodeur/Capteur" -font fnt{3} -aspect 1000 -borderwidth 1 -relief solid
  place 	.top.main.moteurFrame.encoder.info -x 0 -y 0 -relwidth 1
  
  message 	.top.main.moteurFrame.encoder.ref.info -text "Reference" -font fnt{3} -aspect 1000 -borderwidth 1 -relief solid
  place 	.top.main.moteurFrame.encoder.ref.info -x 0 -y 0 -relwidth 1
  
  message 	.top.main.moteurFrame.encoder.etu.info -text "Etudiant" -font fnt{3} -aspect 1000 -borderwidth 1 -relief solid
  place 	.top.main.moteurFrame.encoder.etu.info -x 0 -y 0 -relwidth 1
  
  # cr\E9ation d'une frame pour la gestion du moteur pas \E0 pas
  frame .top.main.moteurFrame.step -borderwidth 2 -relief groove
  place .top.main.moteurFrame.step -x 530 -y 20 -height 270 -width 305
  
  message 	.top.main.moteurFrame.step.info -text "Moteur Pas a pas" -font fnt{3} -aspect 500 -borderwidth 1 -relief solid
  place 	.top.main.moteurFrame.step.info -x 0 -y 0 -relwidth 1
  
  # Cr\E9ation d'une frame pour le SUBD, port 80, LED et switchs
  frame 	.top.main.ioFrame -borderwidth 2 -relief groove
  place 	.top.main.ioFrame -x 0 -y 5 -height 140 -width 840
  
  message 	.top.main.ioFrame.info -text "LEDs et Boutons" -font fnt{3} -aspect 300 -borderwidth 1 -relief solid
  place 	.top.main.ioFrame.info -x 0 -y 0 -relwidth 1
  
  # Cr\E9ation d'une sous-frame pour les LEDs
  frame		.top.main.ioFrame.led -borderwidth 2 -relief groove
  place 	.top.main.ioFrame.led -x 5 -y 25 -height 110 -width 825
 
  message 	.top.main.ioFrame.led.infoled1 -text "LEDs 23..16" -font fnt{4} -aspect 500
  place 	.top.main.ioFrame.led.infoled1 -x 10 -y 25 -relwidth 0.2
  message 	.top.main.ioFrame.led.infoled2 -text "LEDs 15..8" -font fnt{4} -aspect 500
  place 	.top.main.ioFrame.led.infoled2 -x 130 -y 25 -relwidth 0.2
  message 	.top.main.ioFrame.led.infoled3 -text "LEDs 7..0" -font fnt{4} -aspect 500
  place 	.top.main.ioFrame.led.infoled3 -x 250 -y 25 -relwidth 0.2
  message 	.top.main.ioFrame.led.infosw -text "BOUTONS 1..5" -font fnt{4} -aspect 500
  place 	.top.main.ioFrame.led.infosw -x 380 -y 25 -relwidth 0.45
  
  # Create menu
  menu .top.menu -tearoff 0
  set file .top.menu.file
  set run .top.menu.run
  set help .top.menu.help
  menu $file -tearoff 0
  menu $run -tearoff 0
  menu $help -tearoff 0
  .top.menu add cascade -label "Fichier" -menu $file -underline 0
  .top.menu add cascade -label "Run" -menu $run -underline 0
  .top.menu add cascade -label "?" -menu $help -underline 0
  set helpElementNbr 0

  # "Run" menu
  $run add command -label "Run" -command StartStopManager -accelerator "Ctrl-R" \
                   -underline 0
  $run add command -label "Stop" -command StartStopManager -accelerator "Ctrl-S" \
                   -underline 0 -state disabled
  $run add separator
  $run add checkbutton -label "Run continu" -variable continuMode

  # Some bindings for menu accelerator
  bind .top <Control-r> {RunStep}
  bind .top <Control-R> {RunStep}


  # "File" menu
  $file add command -label "Fermer" -command CloseConsole -accelerator "Ctrl-W" \
                    -underline 0
  $file add separator
  $file add command -label "Quitter" -command QuitConsole -accelerator "Ctrl-Q" \
                    -underline 0

  # Some bindings for menu accelerator
  bind .top <Control-w> {CloseConsole}
  bind .top <Control-W> {CloseConsole}
  bind .top <Control-q> {QuitConsole}
  bind .top <Control-Q> {QuitConsole}


  # "Help" menu
  set fexist [file exists $sigImgFile]
  if {$fexist == 1} {
    $help add command -label "Designation des signaux" \
                      -command ShowSignalLabels \
                      -accelerator "Ctrl-H" \
                      -underline 0
    bind .top <Control-h> {ShowSignalLabels}
    bind .top <Control-H> {ShowSignalLabels}
    incr helpElementNbr
  }
  if {$helpElementNbr > 0} {
    $help add separator
  }
  $help add command -label "A propos" \
                    -command ShowAbout \
                    -underline 0


  # Configure menubar
  .top configure -menu .top.menu
  
  # Cr\E9ation des commandes pour le moteur DC
   createButton .top.main.moteurFrame.dc.swref 0 30 0 "" horizontal 1;
   message 	.top.main.moteurFrame.dc.infoswref -text "ETU \n\n\nREF" -font fnt{5} -aspect 300
   place 	.top.main.moteurFrame.dc.infoswref -x 35 -y 30 -relwidth 0.1
   
   createButton .top.main.moteurFrame.dc.swmode 80 30 0 "" horizontal 1;
   message 	.top.main.moteurFrame.dc.infomode -text "PWM \n\n\nOSC" -font fnt{5} -aspect 300
   place 	.top.main.moteurFrame.dc.infomode -x 115 -y 30 -relwidth 0.1
   
   createButton .top.main.moteurFrame.dc.swstdby 170 30 0 "" horizontal 1;
   message 	.top.main.moteurFrame.dc.infostdby -text "STBY_ON \n\n\nSTBY_OFF" -font fnt{5} -aspect 500
   place 	.top.main.moteurFrame.dc.infostdby -x 215 -y 30 -relwidth 0.1
   
   createButton .top.main.moteurFrame.dc.swmanage 270 30 0 "" horizontal 2;
   message 	.top.main.moteurFrame.dc.infosw -text "00 STOP \n01 ANTIHORAIRE \n10 HORAIRE\n11 FREIN" -font fnt{5} -aspect 170
   place 	.top.main.moteurFrame.dc.infosw -x 335 -y 30 -relwidth 0.3
   
   createValue  .top.main.moteurFrame.dc.valueosc  10 150 -Nbr_Value 1 0 0;
   createButton .top.main.moteurFrame.dc.loadosc 180 150 0 "" horizontal 1;
   message 	.top.main.moteurFrame.dc.loadoscTxt -text "Ecriture Courant" -font fnt{5} -aspect 200
   place 	.top.main.moteurFrame.dc.loadoscTxt -x 135 -y 115 -relwidth 0.25
   
   createValue  .top.main.moteurFrame.dc.valuepwm  270 150 -Nbr_Value 1 0 0;
   createButton .top.main.moteurFrame.dc.loadpwm 445 150 0 "" horizontal 1;
   message 	.top.main.moteurFrame.dc.loadpwmTxt -text "Ecriture Rapport" -font fnt{5} -aspect 200
   place 	.top.main.moteurFrame.dc.loadpwmTxt -x 420 -y 115 -relwidth 0.2
   
   createLed 	.top.main.moteurFrame.dc.ledalert	 480 40 1 horizontal 1; 
   message 	.top.main.moteurFrame.dc.alert -text "Alert" -font fnt{4} -aspect 180
   place 	.top.main.moteurFrame.dc.alert -x 470 -y 20 -relwidth 0.1
   
   # Encodeur
   
   # reset counters
   createButton .top.main.moteurFrame.encoder.sw 30 70 0 "" horizontal 1;
   message 	.top.main.moteurFrame.encoder.infosw -text "Reset compteurs" -font fnt{5} -aspect 300
   place 	.top.main.moteurFrame.encoder.infosw -x 0 -y 30 -relwidth 0.13
   
   ## R\E9f\E9rence -----------------------------------------------------------------------------------------
   # compteur de tours de disque
   createResult .top.main.moteurFrame.encoder.ref.rcount   0 40 1 0;
   message 	.top.main.moteurFrame.encoder.ref.rcountTxt -text "Nb de tours" -font fnt{5} -aspect 300
   place 	.top.main.moteurFrame.encoder.ref.rcountTxt -x 0 -y 20 -relwidth 0.25
   
   # compteur de index
   createResult .top.main.moteurFrame.encoder.ref.icount   170 40 1 0;
   message 	.top.main.moteurFrame.encoder.ref.icountTxt -text "Nb d'index" -font fnt{5} -aspect 300
   place 	.top.main.moteurFrame.encoder.ref.icountTxt -x 150 -y 20 -relwidth 0.3
   
   # compteur d'impulsions reference
   createResult .top.main.moteurFrame.encoder.ref.abcount   340 40 1 0;
   message 	.top.main.moteurFrame.encoder.ref.abcountTxt -text "Nb de pas" -font fnt{5} -aspect 300
   place 	.top.main.moteurFrame.encoder.ref.abcountTxt -x 320 -y 20 -relwidth 0.3
      
   # LED sens de rotation
   createLed 	.top.main.moteurFrame.encoder.ref.ledsens	 550 55 1 horizontal 2; 
   message 	.top.main.moteurFrame.encoder.ref.sens -text "Anti-horaire / Horaire" -font fnt{4} -aspect 490
   place 	.top.main.moteurFrame.encoder.ref.sens -x 510 -y 35 -relwidth 0.18
   
   # LED erreur
   createLed 	.top.main.moteurFrame.encoder.ref.error	 660 55 1 horizontal 1; 
   message 	.top.main.moteurFrame.encoder.ref.errortxt -text "Erreur" -font fnt{4} -aspect 200
   place 	.top.main.moteurFrame.encoder.ref.errortxt -x 640 -y 35 -relwidth 0.1
   
   ## Etudiant -----------------------------------------------------------------------------------------
   
   # compteur de tours de disque
   createResult .top.main.moteurFrame.encoder.etu.rcount   0 40 1 0;
   message 	.top.main.moteurFrame.encoder.etu.rcountTxt -text "Nb de tours" -font fnt{5} -aspect 300
   place 	.top.main.moteurFrame.encoder.etu.rcountTxt -x 0 -y 20 -relwidth 0.25
   
   # compteur de index
   createResult .top.main.moteurFrame.encoder.etu.icount   170 40 1 0;
   message 	.top.main.moteurFrame.encoder.etu.icountTxt -text "Nb d'index" -font fnt{5} -aspect 300
   place 	.top.main.moteurFrame.encoder.etu.icountTxt -x 150 -y 20 -relwidth 0.3
   
   # compteur d'impulsions reference
   createResult .top.main.moteurFrame.encoder.etu.abcount   340 40 1 0;
   message 	.top.main.moteurFrame.encoder.etu.abcountTxt -text "Nb de pas" -font fnt{5} -aspect 300
   place 	.top.main.moteurFrame.encoder.etu.abcountTxt -x 320 -y 20 -relwidth 0.3
      
   # LED sens de rotation
   createLed 	.top.main.moteurFrame.encoder.etu.ledsens	 550 55 1 horizontal 2; 
   message 	.top.main.moteurFrame.encoder.etu.sens -text "Anti-horaire / Horaire" -font fnt{4} -aspect 490
   place 	.top.main.moteurFrame.encoder.etu.sens -x 510 -y 35 -relwidth 0.18
   
    
   # LED erreur
   createLed 	.top.main.moteurFrame.encoder.etu.error	 660 55 1 horizontal 1; 
   message 	.top.main.moteurFrame.encoder.etu.errortxt -text "Erreur" -font fnt{4} -aspect 200
   place 	.top.main.moteurFrame.encoder.etu.errortxt -x 640 -y 35 -relwidth 0.1
   
    # compteur d'impulsions etudiant
   #createResult .top.main.moteurFrame.encoder.abcountetu   340 130 1 0;
   #message 	.top.main.moteurFrame.encoder.abcountetuTxt -text "Nb de pas \E9tudiant" -font fnt{5} -aspect 600
   #place 	.top.main.moteurFrame.encoder.abcountetuTxt -x 340 -y 110 -relwidth 0.3
   #------------------------------------------------------------------------------------------------------------------
   # capteur disque
   createLed 	.top.main.moteurFrame.encoder.ledcapt	35 160 1 horizontal 1; 
   message 	.top.main.moteurFrame.encoder.capt -text "Capteur" -font fnt{5} -aspect 220
   place 	.top.main.moteurFrame.encoder.capt -x 10 -y 140 -width 80
   
   # Cr\E9ation des commandes pour le moteur pas \E0 pas
   createButton .top.main.moteurFrame.step.sw 10 20 1 "" horizontal 5;
   message 	.top.main.moteurFrame.step.infosw -text "S4:Etudiant, not Reference\nS3:Tourne, not Stop\nS2:Horaire, not AntiHoraire\nS1:Ecriture d'un d\E9lai\nS0:Ecriture du courant" -font fnt{5} -aspect 1000
   place 	.top.main.moteurFrame.step.infosw -x 1 -y 100 -relwidth 0.8
   
   createValue  .top.main.moteurFrame.step.courant  5 210 -Nbr_Value 1 0 0;
   message 	.top.main.moteurFrame.step.courantTxt -text "Courant" -font fnt{4} -aspect 300
   place 	.top.main.moteurFrame.step.courantTxt -x 1 -y 190 -relwidth 0.5
   
   createValue  .top.main.moteurFrame.step.delai 120 210 -Nbr_Value 1 0 0;
   message 	.top.main.moteurFrame.step.delaiTxt -text "Delai" -font fnt{4} -aspect 300
   place 	.top.main.moteurFrame.step.delaiTxt -x 120 -y 190 -relwidth 0.5
   
   createLed 	.top.main.moteurFrame.step.lederr 	 220 40 1 horizontal 1; 
   message 	.top.main.moteurFrame.step.error -text "Erreur" -font fnt{4} -aspect 300
   place 	.top.main.moteurFrame.step.error -x 200 -y 20 -relwidth 0.3
   
  # cr\E9ation de cases pour la saisie des valeurs des LEDs
   createValue  .top.main.ioFrame.led.value23_16  0 50 -Nbr_Value 1 0 0;
   createValue  .top.main.ioFrame.led.value15_8  120 50 -Nbr_Value 1 0 0;
   createValue  .top.main.ioFrame.led.value7_0  240 50 -Nbr_Value 1 0 0;
   # cr\E9ation des leds pour l'affichage des valeurs des boutons
   createLed 	.top.main.ioFrame.led.led 	 500 50 1 horizontal 5; 
 
  #   Only available in Simulation mode
  if {$runningMode == "Simulation"} {
    createSevenSeg .top.main.outputFrame.sevenSeg 490 20 "7 seg." ;# afficheur 7 seg.
  }

  # Create spinbox for "Continu" mode
  checkbutton .top.continuMode -text "Continu" -font fnt{3} -variable continuMode
  place .top.continuMode -x 505 -y 690

  # Creation de bouton pour la gestion du temps
  #--| Creation de bouton pour la gestion du temps en mode simulation |-----------

  button .top.run -text "Run" -command {StartStopManager} -font fnt{3} -textvariable runText
  place .top.run -x 580 -y 690 -height 22 -width 70

  button .top.restart -text "Restart" -command {RestartSim} -font fnt{3}
  place .top.restart -x 655 -y 690 -height 22 -width 70

  # Creation du bouton "Quitter"
  button .top.exit -text Quitter -command QuitConsole -font fnt{3}
  place .top.exit  -x 730 -y 690 -height 22 -width 70

}


# --| ShowSignalLabels |--------------------------------------------------------------------
# --  Show a side window with the image $images(sigImgLabels)"
# ----------------------------------------------------------------------------------------
proc ShowSignalLabels {} {
  global images sigImgFile windowOpen

  proc CloseSignalLabels {} {
    global windowOpen
    set windowOpen(SignalLabels) FALSE;
    wm withdraw .info;
    destroy .info
  }

  if {$windowOpen(SignalLabels) == FALSE} {
    # Create and arrange the dialog contents.
    toplevel .info

    set windowOpen(SignalLabels) TRUE
    wm protocol .info WM_DELETE_WINDOW {CloseSignalLabels}

    set screenx [winfo screenwidth .top]
    set screeny [winfo screenheight .top]
    set x [expr [winfo x .top] + [winfo width .top] + 10]
    set y [expr [winfo y .top]]
    set width 478
    set height 259

    if {[expr $x + $width] > [expr $screenx]} {
      set x [expr $x - [winfo width .top] - $width - 10]
    }

    # Canvas for the boat image
    canvas .info.cimg -height $height -width $width
    place .info.cimg -x 0 -y 0

    set images(sigImgLabels) [image create photo -file "$sigImgFile"]; puts ""
    .info.cimg create image [expr $width/2] [expr $height/2] -image $images(sigImgLabels)

    wm geometry  .info [expr $width]x[expr $height]+$x+$y
    wm resizable  .info 0 0
    wm title     .info "Designation des signaux"
    wm deiconify .info
  }
}


# --| ShowAbout |--------------------------------------------------------------------
# --  Show the "About" window
# ----------------------------------------------------------------------------------------
proc ShowAbout {} {
    global infoLabel windowOpen consoleInfo

  proc CloseAbout {} {
    global windowOpen
    set windowOpen(About) FALSE;
    wm withdraw .about;
    destroy .about

    wm attributes .top -disabled FALSE
    wm attributes .top -alpha 1.0
  }

  if {$windowOpen(About) == FALSE} {
    # Create and arrange the dialog contents.
    toplevel .about

    set windowOpen(About) TRUE
    wm protocol .about WM_DELETE_WINDOW {CloseAbout}
    
    # Disable top
    wm attributes .top -disabled TRUE
    wm attributes .top -alpha 0.8

    set width 250
    set height 200

    set x [expr [winfo x .top]+[winfo width .top]/2-$width/2]
    set y [expr [winfo y .top]+[winfo height .top]/2-$height/2]

    button .about.ok -text OK -command {CloseAbout}
    place .about.ok -x [expr $width/2] -y [expr $height-20] -width 70 -height 30 -anchor s

    set infoLabel "$consoleInfo(title) version $consoleInfo(version) \
                   \n\nAuteur:\nDuployer/Lolivier-Exler
                   \n\nREDS (c) 2014 - [clock format [clock seconds] -format %Y]"
    label .about.label -textvariable infoLabel -font fnt{5} -justify center
    place .about.label -x [expr $width/2] -y 20 -anchor n

    wm geometry  .about [expr $width]x[expr $height]+$x+$y
    wm title     .about "\C0 propos"
    wm transient .about .top
    wm attributes .about -topmost 1; # On top fo all
    wm resizable  .about 0 0; # Cannot resize
    wm frame .about

  }
}


# --| ShowSignalList |--------------------------------------------------------------------
# --  Show a side window with the content of file "SignalList.txt"
# ----------------------------------------------------------------------------------------
proc ShowSignalList {} {
  global infoLabel

  # Create and arrange the dialog contents.
  toplevel .info

  set x [expr [winfo x .top] + [winfo width .top] + 10]
  set y [expr [winfo y .top]]

  #button .info.ok -text OK -command {wm withdraw .info;   destroy .info}
  #place .info.ok -x 275  -y 190 -width 65 -height 20
  text .info.text -yscrollcommand ".info.scroll set"
  scrollbar .info.scroll -command ".info.text yview"

  set infoLabel ""
  label .info.label -textvariable infoLabel -font fnt{5} -justify left
  place .info.label -x 5 -x 5

  set firstLine TRUE

  set fileId [open ./SignalList.txt r]
  while {![eof $fileId]} {
    set line [gets $fileId]
    if {$firstLine == TRUE} {
      set infoLabel "$line"
      set firstLine FALSE
    } else {
      set infoLabel "$infoLabel\n$line"
    }
  }

  close $fileId

  wm geometry  .info 350x287+$x+$y
  wm resizable  .info 0 0
  wm title     .info "Designation des signaux"
  wm deiconify .info

}


# --| NbrToBit |--------------------------------------------------------------------------
# --  Transformation d'une valeur en une string du nombre en representation binaire.
# --  Nbr_Bits = nbr bit de la conversion
# ----------------------------------------------------------------------------------------
proc NbrToBit {Value {Nbr_Bits 8}} {

    set bitList [list ]
    set Index [expr $Nbr_Bits -1]
    set Val_Max [expr (pow(2,$Nbr_Bits)) -1]

    if {($Value < 0) || ($Value > $Val_Max)} {
        set bitList UUUUUUUU
    } else {
        for {set i $Index} {$i>=0} {set i [expr $i-1]} {
        set mask [expr int(pow(2,$i))]
        set tmp [expr $mask & $Value]
        if {$tmp} {
            set tmp 1
        }
        set bitList [linsert $bitList end $tmp]
      }
      set bitList [join $bitList ""]
    }
    return $bitList
}


# --| Dec2Bin |---------------------------------------------------------------------------
# --  Transform a decimal value to a binary string. (Max 32-bits)
# --    - Value:   The value to be converted
# --    - NbrBits: Number of bit of "Value"
# --    - Dest
# ----------------------------------------------------------------------------------------
proc Dec2Bin {Value {NbrBits 8} {DestBits 8} {Signed true}} {
  global lblTestVal

  set BitList []
  set Index [expr $NbrBits -1]
  set SignedValMin [expr -(pow(2,$NbrBits-1))]
  set SignedValMax [expr pow(2,$NbrBits-1)-1]
  set UnsignedValMin 0
  set UnsignedValMax [expr pow(2,$NbrBits-1)-1]
  set Negative false

  # Prevent shorter destination... subjective choice
  if {$DestBits < $NbrBits} {
    set DestBits $NbrBits
  }

  # Calculate the limits according to the mode (signed/unsigned)
  if {$Signed} {
    set ValMin $SignedValMin
    set ValMax $SignedValMax
  } else {
    set ValMin $UnsignedValMin
    set ValMax $UnsignedValMax
  }

  # Warn if $Value overflow the capacity according to $NbrBits
  # if {($Value < $ValMin) || ($Value > $ValMax)} {
  #   set ttl "D\E9passement de capacit\E9"
  #   if {$Signed} {set Sign "sign\E9"} else {set Sign "non-sign\E9"}
  #   set msg "Le nombre $Value ($Sign) d\E9passe la capacit\E9 ($NbrBits-bits) du vecteur."
  #   tk_messageBox -parent .top -icon warning -type ok -title $ttl -message $msg
  # }

  # Convert $Value to a 32-bits binary number BinRep
  set BinRep [binary format I $Value]

  # Convert $BinRep to a binary string
  binary scan $BinRep B* BinStr

  # Return result, cut it according to $NbrBits
  set LastBit [string length $BinStr]

  # Propagate MSB for signed values
  if {$Signed} {
    set MSB [string range $BinStr [expr $LastBit-$NbrBits] [expr $LastBit-$NbrBits]]
    set ZeroStr [string repeat $MSB [expr $LastBit-$NbrBits]]
    set BinStr [string replace $BinStr 0 [expr $LastBit-$NbrBits-1] $ZeroStr]
    #set lblTestVal "$BinStr\n$ZeroStr"
  }

  return [string range $BinStr [expr $LastBit-$DestBits] $LastBit]
}


# --| Bin2Dec |---------------------------------------------------------------------------
# --  Tranform a binary string to an integer
# ----------------------------------------------------------------------------------------
proc Bin2Dec {binString} {

  set result 0
  for {set j 0} {$j < [string length $binString]} {incr j} {
      set bit [string range $binString $j $j]
      if {$bit == "X" || $bit == "U"} {
        set bit 0
      }
      set result [expr $result << 1]
      set result [expr $result | $bit]
  }
  return $result
}

proc Bin2Int {binString} {
  set result 0

  set lastBit [expr [string length $binString]-1]
  #set signBit [string range $binString $lastBit $lastBit]

  set ttl "Controle des valeurs"
  set msg "$lastBit / $signBit"

  tk_messageBox -parent .top -icon warning -type ok -title $ttl -message $msg

  for {set j 0} {$j < [string length $binString]} {incr j} {
      set bit [string range $binString $j $j]
      set result [expr $result << 1]
      set result [expr $result | $bit]
  }
  return $result
}



# --| SetOutputs |-------------------------------------------------------------------------
# --  Affectation des signaux
# ----------------------------------------------------------------------------------------
proc SetOutputs {} {
  global runningMode adrDataPin adrConfPin adrResetConf \
			adrResetData ConfigPIdebugLabel debugMode nbrPas

  # # Affectation des OE pour le SUB25 en fonction de la valeur du switch
  # set singleSwitchState [readButton .top.main.ioFrame.subd.switch 0]
    # if {$singleSwitchState == 1} {
		# set ConfigPinD01_08 [format %d 0xff]; # 1111 1111
		# set ConfigPinD09_16 [format %d 0xff]; # 1111 1111
		# set ConfigPinD17_24 [format %d 0x00]; # 0000 0000
		# set ConfigPinD25_27 [format %d 0x00]; # 0000 0000
    # } else {
		# set ConfigPinD01_08 [format %d 0x00]; # 0000 0000
		# set ConfigPinD09_16 [format %d 0x00]; # 0000 0000
		# set ConfigPinD17_24 [format %d 0xff]; # 1111 1111
		# set ConfigPinD25_27 [format %d 0xff]; # 1111 1111
	# }
  
   # # Configuration for the right SUB25 connector 
  # EcrireUSB $adrConfPin(D01_08) $ConfigPinD01_08
  # EcrireUSB $adrConfPin(D09_16) $ConfigPinD09_16
  # EcrireUSB $adrConfPin(D17_24) $ConfigPinD17_24
  # EcrireUSB $adrConfPin(D25_27) $ConfigPinD25_27
  
  # # Affectation des OE pour le port80 en fonction de la valeur du switch
  # set singleSwitchState [readButton .top.main.ioFrame.port80.switch 0]
    # if {$singleSwitchState == 1} {
	  # # Configuration for the 80 poles connector 
		# set adrConfPinE01_08 [format %d 0xff]; # 1111 1111
		# set adrConfPinE09_16 [format %d 0xff]; # 1111 1111
		# set adrConfPinE17_24 [format %d 0xff]; # 1111 1111
		# set adrConfPinE25_32 [format %d 0xff]; # 1111 1111
		# set adrConfPinE33_40 [format %d 0xff]; # 1111 1111
		# set adrConfPinE41_48 [format %d 0x00]; # 0000 0000
		# set adrConfPinE49_56 [format %d 0x00]; # 0000 0000
		# set adrConfPinE57_64 [format %d 0x00]; # 0000 0000 
		# set adrConfPinE65_72 [format %d 0x00]; # 0000 0000
		# set adrConfPinE73_80 [format %d 0x00]; # 0000 0000   
    # } else {
		# set adrConfPinE01_08 [format %d 0x00]; # 0000 0000
		# set adrConfPinE09_16 [format %d 0x00]; # 0000 0000
		# set adrConfPinE17_24 [format %d 0x00]; # 0000 0000
		# set adrConfPinE25_32 [format %d 0x00]; # 0000 0000
		# set adrConfPinE33_40 [format %d 0x00]; # 0000 0000
		# set adrConfPinE41_48 [format %d 0xff]; # 1111 1111
		# set adrConfPinE49_56 [format %d 0xff]; # 1111 1111
		# set adrConfPinE57_64 [format %d 0xff]; # 1111 1111 
		# set adrConfPinE65_72 [format %d 0xff]; # 1111 1111
		# set adrConfPinE73_80 [format %d 0xff]; # 1111 1111   
	# }
	                               
  # EcrireUSB $adrConfPin(E01_08) $adrConfPinE01_08
  # EcrireUSB $adrConfPin(E09_16) $adrConfPinE09_16
  # EcrireUSB $adrConfPin(E17_24) $adrConfPinE17_24
  # EcrireUSB $adrConfPin(E25_32) $adrConfPinE25_32
  # EcrireUSB $adrConfPin(E33_40) $adrConfPinE33_40
  # EcrireUSB $adrConfPin(E41_48) $adrConfPinE41_48
  # EcrireUSB $adrConfPin(E49_56) $adrConfPinE49_56
  # EcrireUSB $adrConfPin(E57_64) $adrConfPinE57_64
  # EcrireUSB $adrConfPin(E65_72) $adrConfPinE65_72
  # EcrireUSB $adrConfPin(E73_80) $adrConfPinE73_80

  # # Lecture des valeurs que l'on souhaite mettre dans le SUB, le port 80 et les LEDs
  # set valA_SUBEntry [readValue .top.main.ioFrame.subd.value A]
  # set valB_SUBEntry [readValue .top.main.ioFrame.subd.value B]
  # set valC_SUBEntry [readValue .top.main.ioFrame.subd.value C]
  # set valD_SUBEntry [readValue .top.main.ioFrame.subd.value D]
  
  # set valA_80polesEntry [readValue .top.main.ioFrame.port80.value A]
  # set valB_80polesEntry [readValue .top.main.ioFrame.port80.value B]
  # set valC_80polesEntry [readValue .top.main.ioFrame.port80.value C]
  # set valD_80polesEntry [readValue .top.main.ioFrame.port80.value D]
  # set valE_80polesEntry [readValue .top.main.ioFrame.port80.value E]
  # set valF_80polesEntry [readValue .top.main.ioFrame.port80.value F]
  # set valG_80polesEntry [readValue .top.main.ioFrame.port80.value G]
  # set valH_80polesEntry [readValue .top.main.ioFrame.port80.value H]
  # set valI_80polesEntry [readValue .top.main.ioFrame.port80.value I]
  # set valJ_80polesEntry [readValue .top.main.ioFrame.port80.value J]
  
  set valA_LEDEntry [readValue .top.main.ioFrame.led.value23_16 A]
  set valB_LEDEntry [readValue .top.main.ioFrame.led.value15_8 A]
  set valC_LEDEntry [readValue .top.main.ioFrame.led.value7_0 A]
  
  # Moteur pas \E0 pas
  set valTension_stepper [readValue .top.main.moteurFrame.step.courant A]
  set valDelai_stepper [readValue .top.main.moteurFrame.step.delai A]  
  
  # Moteur DC
  set val_DC_duty [readValue .top.main.moteurFrame.dc.valuepwm A]
  set val_DC_vref [readValue .top.main.moteurFrame.dc.valueosc A]
  
  
  
   
  # Affectation des valeurs aux signaux respectifs
  if {$runningMode == "Simulation"} {
    # for {set i 0} {$i < 8} {incr i} {
    # force -freeze /Top_Sim/S$i\_i $singleSwitchState($i)
    #}
    # force -freeze /Top_Sim/Val_A_SUB_i [Dec2Bin $valA_SUBEntry 8]
    # force -freeze /Top_Sim/Val_B_SUB_i [Dec2Bin $valB_SUBEntry 8]
    # force -freeze /Top_Sim/Val_C_SUB_i [Dec2Bin $valC_SUBEntry 8]
    # force -freeze /Top_Sim/Val_D_SUB_i [Dec2Bin $valD_SUBEntry 8]
	
	# force -freeze /Top_Sim/Val_A_port80_i [Dec2Bin $valA_80polesEntry 8]
    # force -freeze /Top_Sim/Val_B_port80_i [Dec2Bin $valB_80polesEntry 8]
    # force -freeze /Top_Sim/Val_C_port80_i [Dec2Bin $valC_80polesEntry 8]
    # force -freeze /Top_Sim/Val_D_port80_i [Dec2Bin $valD_80polesEntry 8]
	# force -freeze /Top_Sim/Val_E_port80_i [Dec2Bin $valE_80polesEntry 8]
    # force -freeze /Top_Sim/Val_F_port80_i [Dec2Bin $valF_80polesEntry 8]
    # force -freeze /Top_Sim/Val_G_port80_i [Dec2Bin $valG_80polesEntry 8]
    # force -freeze /Top_Sim/Val_H_port80_i [Dec2Bin $valH_80polesEntry 8]
	# force -freeze /Top_Sim/Val_I_port80_i [Dec2Bin $valI_80polesEntry 8]
    # force -freeze /Top_Sim/Val_J_port80_i [Dec2Bin $valJ_80polesEntry 8]
	
	# concernant les LEDs
	force -freeze /console_sim/Val_A_LED_sti [Dec2Bin $valA_LEDEntry 8]
	force -freeze /console_sim/Val_B_LED_sti [Dec2Bin $valB_LEDEntry 8]
	force -freeze /console_sim/Val_C_LED_sti [Dec2Bin $valC_LEDEntry 8]
  } else {
	# # Ecriture sur le SUBD
    # EcrireUSB $adrDataPin(D01_08) $valA_SUBEntry
    # EcrireUSB $adrDataPin(D09_16) $valB_SUBEntry
    # EcrireUSB $adrDataPin(D17_24) $valC_SUBEntry
    # EcrireUSB $adrDataPin(D25_27) $valD_SUBEntry
    # # EcrireUSB $adrDataPin(D17_24) $switchesStates
	
	# # Ecriture sur le port 80
	# EcrireUSB $adrDataPin(E01_08) $valA_80polesEntry
    # EcrireUSB $adrDataPin(E09_16) $valB_80polesEntry
    # EcrireUSB $adrDataPin(E17_24) $valC_80polesEntry
    # EcrireUSB $adrDataPin(E25_32) $valD_80polesEntry
	# EcrireUSB $adrDataPin(E33_40) $valE_80polesEntry
    # EcrireUSB $adrDataPin(E41_48) $valF_80polesEntry
    # EcrireUSB $adrDataPin(E49_56) $valG_80polesEntry
    # EcrireUSB $adrDataPin(E57_64) $valH_80polesEntry
	# EcrireUSB $adrDataPin(E65_72) $valI_80polesEntry
    # EcrireUSB $adrDataPin(E73_80) $valJ_80polesEntry
	
	# Ecriture des LEDs
    EcrireUSB $adrDataPin(L01_08) $valA_LEDEntry
    EcrireUSB $adrDataPin(L09_16) $valB_LEDEntry
    EcrireUSB $adrDataPin(L17_24) $valC_LEDEntry
		
	# Ecrit le courant desir\E9e dans le cas du moteur PAP ou la valeur de VREF dans le cas du moteur DC en mode OSC
	set switchLoadOsc [readButton .top.main.moteurFrame.dc.loadosc 0]
	set switchLoadPap [readButton .top.main.moteurFrame.step.sw 0]
	
	if {$switchLoadOsc == 1} {
		EcrireUSB $adrDataPin(Courant) $val_DC_vref
	} else {
		if {$switchLoadPap == 1} {
			EcrireUSB $adrDataPin(Courant) $valTension_stepper
		}
	}
	# Moteur DC
	
	# Ecrit le rapport cyclique d\E9sir\E9 du PWM pour le moteur DC
	EcrireUSB $adrDataPin(Duty) $val_DC_duty
	
	
	# Mode Ref ou Etu pour le moteur DC	
	set singleSwitchState [readButton .top.main.moteurFrame.dc.swref 0]
    if {$singleSwitchState == 1} {
		EcrireUSB $adrDataPin(DcModeEtu) 1
	} else {
		EcrireUSB $adrDataPin(DcModeEtu) 0
	}	
	
	# Mode OSC ou PWM	
	set singleSwitchState [readButton .top.main.moteurFrame.dc.swmode 0]
    if {$singleSwitchState == 1} {
		EcrireUSB $adrDataPin(Mode) 1
	} else {
		EcrireUSB $adrDataPin(Mode) 0
	}	
	
	# S\E9lection du mode (StandBy, Stop, CW, CCW)
	
	set singleSwitchState [readButton .top.main.moteurFrame.dc.swstdby 0]
	if {$singleSwitchState == 1} {
		# StandBy
		EcrireUSB $adrDataPin(RunMode) 00000000
	} else {
		set singleSwitchState [readButton .top.main.moteurFrame.dc.swmanage 0]
		if {$singleSwitchState == 1} {
			set singleSwitchState [readButton .top.main.moteurFrame.dc.swmanage 1]
			if {$singleSwitchState == 1} {	
				# Short Brake: IN1 IN2 nSB = 111
				EcrireUSB $adrDataPin(RunMode) 00000111
				
			} else {
				# CCW: IN1 IN2 nSB = 011
				EcrireUSB $adrDataPin(RunMode) 00000011
			}	
		} else {
			set singleSwitchState [readButton .top.main.moteurFrame.dc.swmanage 1]
			if {$singleSwitchState == 1} {
				# CW: IN1 IN2 nSB = 101
				EcrireUSB $adrDataPin(RunMode) 00000101
			} else {
				# Stop: IN1 IN2 nSB = 001
				EcrireUSB $adrDataPin(RunMode) 00000001
			}	
		}	
	}
	
	# Signal d'autorisation d'\E9criture du rapport cyclique PWM
	set switchLoadPwm [readButton .top.main.moteurFrame.dc.loadpwm 0]
	if {$switchLoadPwm == 1} {
		EcrireUSB $adrDataPin(WR_Duty) 1
	} else {
		EcrireUSB $adrDataPin(WR_Duty) 0
	}
	
	# Signal d'autorisation d'\E9criture de Vref (mode OSC)
	if {$switchLoadOsc == 1} {
		EcrireUSB $adrDataPin(WR_Vref) 1
	} else {
		EcrireUSB $adrDataPin(WR_Vref) 0
	}

## Moteur Pas \E0 Pas		
	# Ecrit le d\E9lai desir\E9
	EcrireUSB $adrDataPin(Delay) $valDelai_stepper	
	
	# Mode Ref ou Etu pour le moteur PAP	
	set singleSwitchState [readButton .top.main.moteurFrame.step.sw 4]
    if {$singleSwitchState == 1} {
		EcrireUSB $adrDataPin(PapModeEtu) 1
	} else {
		EcrireUSB $adrDataPin(PapModeEtu) 0
	}	

	# Turn_nStop (Enable)
	set singleSwitchState [readButton .top.main.moteurFrame.step.sw 3]
    if {$singleSwitchState == 1} {
		EcrireUSB $adrDataPin(StepEn) 1
	} else {
		EcrireUSB $adrDataPin(StepEn) 0
	}
	
	# Horaire, not antihoraire
	set singleSwitchState [readButton .top.main.moteurFrame.step.sw 2]
    if {$singleSwitchState == 1} {
		EcrireUSB $adrDataPin(CCW_nCW) 0
	} else {
		EcrireUSB $adrDataPin(CCW_nCW) 1
	}
	
	# Signal d'autorisation d'\E9criture du d\E9lai
	set singleSwitchState [readButton .top.main.moteurFrame.step.sw 1]
    if {$singleSwitchState == 1} {
		EcrireUSB $adrDataPin(DelayWR)  1
	} else {
		EcrireUSB $adrDataPin(DelayWR)  0
	}
		
	# Signal d'autorisation d'\E9criture du courant
	set singleSwitchState [readButton .top.main.moteurFrame.step.sw 0]
    if {$singleSwitchState == 1} {
		EcrireUSB $adrDataPin(CurWR) 1
	} else {
		EcrireUSB $adrDataPin(CurWR) 0
	}
	
	# Compteur encodeur
	set EncResetCnt [readButton .top.main.moteurFrame.encoder.sw 0]
	
	if {$EncResetCnt == 1} {
		EcrireUSB $adrDataPin(EncResetCnt) 1
	} else {
		EcrireUSB $adrDataPin(EncResetCnt) 0
	}
	
  }
  

  
  
  if {$debugMode == TRUE} {
    set debugLabel(1) "VA:$valA_SUBEntry|VB:$valB_SUBEntry|VB:$valC_SUBEntry|VB:$valD_SUBEntry|S:$switchesStates"
  }
}


# --| ReadInputs |-----------------------------------------------------------------------
# --  Lecture des entrees
# ----------------------------------------------------------------------------------------
proc ReadInputs {} {
  global runningMode adrDataPin debugLabel debugMode nbrPas

  # --------------------------------------------------------------------------------------
  # Lecture des valeurs des entr\E9es
  # --------------------------------------------------------------------------------------
  array set singleLedState {
    0 0
    1 0
    2 0
    3 0
    4 0
    5 0
    6 0
    7 0
  }

  if {$runningMode == "Simulation"} {
    set Hex0 [examine -unsigned /console_sim/Hex0_obs]
    set Hex1 [examine -unsigned /console_sim/Hex1_obs]
    # set Result_A_SUB [Bin2Dec [examine -unsigned /console_sim/Result_A_SUB_obs]]
    # set Result_B_SUB [Bin2Dec [examine -unsigned /console_sim/Result_B_SUB_obs]]
    # set Result_C_SUB [Bin2Dec [examine -unsigned /console_sim/Result_C_SUB_obs]]
    # set Result_D_SUB [Bin2Dec [examine -unsigned /console_sim/Result_D_SUB_obs]]	
	
	# set Result_A_port80 [Bin2Dec [examine -unsigned /console_sim/Result_A_port80_obs]]
    # set Result_B_port80 [Bin2Dec [examine -unsigned /console_sim/Result_B_port80_obs]]
    # set Result_C_port80 [Bin2Dec [examine -unsigned /console_sim/Result_C_port80_obs]]
    # set Result_D_port80 [Bin2Dec [examine -unsigned /console_sim/Result_D_port80_obs]]	
	# set Result_E_port80 [Bin2Dec [examine -unsigned /console_sim/Result_E_port80_obs]]
    # set Result_F_port80 [Bin2Dec [examine -unsigned /console_sim/Result_F_port80_obs]]
    # set Result_G_port80 [Bin2Dec [examine -unsigned /console_sim/Result_G_port80_obs]]
    # set Result_H_port80 [Bin2Dec [examine -unsigned /console_sim/Result_H_port80_obs]]	
	# set Result_I_port80 [Bin2Dec [examine -unsigned /console_sim/Result_I_port80_obs]]
    # set Result_J_port80 [Bin2Dec [examine -unsigned /console_sim/Result_J_port80_obs]]
	
    for {set i 0} {$i<8} {incr i} {
      set singleLedState($i) [examine  /console_sim/L$i\_obs]
    }
  } else {
    ## /!\ LECTURE SUR CONSOLE USB2 /!\ ##
    # set Result_A_SUB [LireUSB $adrDataPin(D01_08)]
    # set Result_B_SUB [LireUSB $adrDataPin(D09_16)]
	# set Result_C_SUB [LireUSB $adrDataPin(D17_24)]
    # set Result_D_SUB [LireUSB $adrDataPin(D25_27)]
	
	# set Result_A_port80 [LireUSB $adrDataPin(E01_08)]
    # set Result_B_port80 [LireUSB $adrDataPin(E09_16)]
	# set Result_C_port80 [LireUSB $adrDataPin(E17_24)]
    # set Result_D_port80 [LireUSB $adrDataPin(E25_32)]
	# set Result_E_port80 [LireUSB $adrDataPin(E33_40)]
    # set Result_F_port80 [LireUSB $adrDataPin(E41_48)]
	# set Result_G_port80 [LireUSB $adrDataPin(E49_56)]
    # set Result_H_port80 [LireUSB $adrDataPin(E57_64)]
	# set Result_I_port80 [LireUSB $adrDataPin(E65_72)]
    # set Result_J_port80 [LireUSB $adrDataPin(E73_80)]
		
	# Lecture des switchs
    set ledsState [LireUSB $adrDataPin(S01_05)]
    for {set i 0} {$i<6} {incr i} {
	
	  if {$i == 5} {
		set ledsState [LireUSB $adrDataPin(Error)]
		} 		
      set j [expr $i+1]
      if {[expr $ledsState % int(pow(2,$j))] == int(pow(2,$i))} {
        set singleLedState($i) 1
        set ledsState [expr $ledsState - int(pow(2,$i))];
      } else {
        set singleLedState($i) 0
      }
	  
	# TODO :  lectures des erreurs des moteurs
	# ...
	
	## Encodeur

	set ledCapt  [LireUSB $adrDataPin(EncCapt)]
	
	# ref
	
	set ledSenseRef [LireUSB $adrDataPin(EncRefSense)]
	set ledErrorRef [LireUSB $adrDataPin(EncRefErr)]
	
	set nb_tours_lo_ref [LireUSB $adrDataPin(EncRevRefLo)]
	set nb_tours_hi_ref [LireUSB $adrDataPin(EncRevRefHi)]
	
	set nb_index_lo_ref [LireUSB $adrDataPin(EncIndexRefLo)]
	set nb_index_hi_ref [LireUSB $adrDataPin(EncIndexRefHi)]
	
	set nb_pulse_lo_ref [LireUSB $adrDataPin(EncPulseRefLo)]
	set nb_pulse_hi_ref [LireUSB $adrDataPin(EncPulseRefHi)]
	
	# etu
	
	set ledSenseEtu [LireUSB $adrDataPin(EncEtuSense)]
	set ledErrorEtu [LireUSB $adrDataPin(EncEtuErr)]
	
	set nb_tours_lo_etu [LireUSB $adrDataPin(EncRevEtuLo)]
	set nb_tours_hi_etu [LireUSB $adrDataPin(EncRevEtuHi)]
	
	set nb_index_lo_etu [LireUSB $adrDataPin(EncIndexEtuLo)]
	set nb_index_hi_etu [LireUSB $adrDataPin(EncIndexEtuHi)]
	
	set nb_pulse_lo_etu [LireUSB $adrDataPin(EncPulseEtuLo)]
	set nb_pulse_hi_etu [LireUSB $adrDataPin(EncPulseEtuHi)]
	
	
    }
	
  }

  if {$debugMode == TRUE} {
    set debugLabel(0) "RA:$Result_A_SUB|RB:$Result_B_SUB|L:$ledsState"
  }

  # --------------------------------------------------------------------------------------
  # Mise \E0 jour des affichages
  # --------------------------------------------------------------------------------------

  if {$runningMode == "Simulation"} {
    # Lecture de l'etat de l'afficher 7 segments
    set listSeg {a b c d e f g}
    foreach Seg $listSeg {
      set tmpSeg [examine  /console_sim/seg7_$Seg\_obs]
      if {$tmpSeg == "U"} {
        set tmpSeg 0
      }
      if {$tmpSeg} {
        setSevenSeg .top.main.outputFrame.sevenSeg $Seg ON
      } else {
        setSevenSeg .top.main.outputFrame.sevenSeg $Seg OFF
      }
    }
  }

  # Affichage des LEDs
  for {set i 0} {$i<6} {incr i} {
  # Affichage LED erreur du moteur PAP
	if {$i == 5} {
	    if {$singleLedState($i) == "1"} {
		  setLed .top.main.moteurFrame.step.lederr  0 ON
		} else {
		  setLed .top.main.moteurFrame.step.lederr  0 OFF
		}
	}
  # Affichage des 5 LEDs des switchs
    if {$singleLedState($i) == "1"} {
      setLed .top.main.ioFrame.led.led  [expr 4-$i]  ON
    } else {
      setLed .top.main.ioFrame.led.led  [expr 4-$i] OFF
    }
  }  
  
  

  # TODO : Affichage des erreurs des moteurs sur les LEDs
  # ...
  
  # Affichage LED sens de rotation du disque (R\E9f\E9rence)
   if {$ledSenseRef == 1} {
      setLed .top.main.moteurFrame.encoder.ref.ledsens  0 ON
	  setLed .top.main.moteurFrame.encoder.ref.ledsens  1 OFF
    } else {
	  if {$ledSenseRef == 2} {
        setLed .top.main.moteurFrame.encoder.ref.ledsens  1 ON
	    setLed .top.main.moteurFrame.encoder.ref.ledsens  0 OFF
	  } else {
	    setLed .top.main.moteurFrame.encoder.ref.ledsens  1 OFF
	    setLed .top.main.moteurFrame.encoder.ref.ledsens  0 OFF
	  }
    }
	
	# Affichage LED sens de rotation du disque (Etudiant)
   if {$ledSenseEtu == 1} {
      setLed .top.main.moteurFrame.encoder.etu.ledsens  0 ON
	  setLed .top.main.moteurFrame.encoder.etu.ledsens  1 OFF
    } else {
	  if {$ledSenseEtu == 2} {
        setLed .top.main.moteurFrame.encoder.etu.ledsens  1 ON
	    setLed .top.main.moteurFrame.encoder.etu.ledsens  0 OFF
	  } else {
	    setLed .top.main.moteurFrame.encoder.etu.ledsens  1 OFF
	    setLed .top.main.moteurFrame.encoder.etu.ledsens  0 OFF
	  }
    }
	
   # Affichage LED capteur de disque (seulement bit LSB -> capteur 1)
   
    if {$ledCapt == 1} { 
      setLed .top.main.moteurFrame.encoder.ledcapt  0 ON
    } else {
	  setLed .top.main.moteurFrame.encoder.ledcapt  0 OFF
    }
	
	# Affichage LED Erreur de d\E9tection, mode r\E9f\E9rence
	if {$ledErrorRef == 1} {
	  setLed .top.main.moteurFrame.encoder.ref.error 0 ON
	} else {
	  setLed .top.main.moteurFrame.encoder.ref.error 0 OFF
	}
	
	
	# Affichage LED Erreur de d\E9tection, mode \E9tudiant
	if {$ledErrorEtu == 1} {
	  setLed .top.main.moteurFrame.encoder.etu.error 0 ON
	} else {
	  setLed .top.main.moteurFrame.encoder.etu.error 0 OFF
	}
	
	
  
  ## Affichage des compteurs de l'encodeur du moteur DC (R\E9f\E9rence)
  
  # compteur de tours complets
   set nb_tours_shift  [expr $nb_tours_hi_ref << 8]
   setResult  .top.main.moteurFrame.encoder.ref.rcount A [expr $nb_tours_shift + $nb_tours_lo_ref]
   
  # compteur d'index
   set nb_index_shift  [expr $nb_index_hi_ref << 8]
   setResult  .top.main.moteurFrame.encoder.ref.icount A [expr $nb_index_shift + $nb_index_lo_ref]
   
   # compteur d'impulsions - reference
   set nb_pulse_shift  [expr $nb_pulse_hi_ref << 8]
   setResult  .top.main.moteurFrame.encoder.ref.abcount A [expr $nb_pulse_shift + $nb_pulse_lo_ref]
   
   #--------------------------------------------------------------------------------------------------------
   
   ## Affichage des compteurs de l'encodeur du moteur DC (Etudiant)
  
  # compteur de tours complets
   set nb_tours_shift  [expr $nb_tours_hi_etu << 8]
   setResult  .top.main.moteurFrame.encoder.etu.rcount A [expr $nb_tours_shift + $nb_tours_lo_etu]
   
  # compteur d'index
   set nb_index_shift  [expr $nb_index_hi_etu << 8]
   setResult  .top.main.moteurFrame.encoder.etu.icount A [expr $nb_index_shift + $nb_index_lo_etu]
   
   # compteur d'impulsions - reference
   set nb_pulse_shift  [expr $nb_pulse_hi_etu << 8]
   setResult  .top.main.moteurFrame.encoder.etu.abcount A [expr $nb_pulse_shift + $nb_pulse_lo_etu]
   
}


# --| RunDisplay |------------------------------------------------------------------------
# --  Son role est de forcer les valeurs des entrees, de faire avancer le temps
# --  et enfin d'affecter les valeurs obtenues
# ----------------------------------------------------------------------------------------
proc RunDisplay {} {
  global runningMode runText adrDataPin

  # Affectation des sorties
  SetOutputs  
    
  # Avancement du temps
  if {$runningMode == "Simulation"} {
    run 100 ns
  } else {
    ## Target mode...
    after 1 {
        set continue 1
    }
    vwait continue
    update
    set continue 0
  }

  # Lecture des entr\E9es
  ReadInputs
}

proc StartStopManager {} {
  global runText continuMode

  if {$runText == "Stop"} {
    set runText Run
    .top.menu.run entryconfigure 0 -state normal
    .top.menu.run entryconfigure 1 -state disabled
  } else {
    if {$continuMode == 1} {
      set runText Stop
      .top.menu.run entryconfigure 0 -state disabled
      .top.menu.run entryconfigure 1 -state normal
      RunContinu
    } else {
      RunDisplay
    }
  }
}

 # proc RunContinu {} {
   # global runText speed

   # while {$runText=="Stop"} {
     # after $speed(Refresh) {
       # RunDisplay
	   # set continue 1
     # }
     # vwait continue
     # update
     # set continue 0
   # }
 # }
 
 proc RunContinu {} {
   global runText

   while {$runText=="Stop"} {
     ReadInputs
	 update
	 SetOutputs
    }
 }




# --| RestartSim |------------------------------------------------------------------------
# --  Gestion du redemarage d'une simulation
# ----------------------------------------------------------------------------------------
proc RestartSim {} {
  global runningMode

  # Red\E9marrage de la simulation
  if {$runningMode == "Simulation"} {
    restart -f
  }

  # Lecture des entr\E9es
  ReadInputs

  # initialisatin des variables d'entrees
  initButton .top.main.inputFrame.switch
  setResult  .top.main.outputFrame.result A ""
  setResult  .top.main.outputFrame.result B ""

  if {$runningMode == "Target"} {
    RunDisplay
  }
}


# --| CONFIGWAVES |-----------------------------------------------------------------------
# --  Add signals to the wave view in QuestaSim
# ----------------------------------------------------------------------------------------
proc ConfigWaves {} {
  # Delete all remaining signals in the wave view
  delete wave *

  array set signalList {
    S0_sti        in
    S1_sti        in
    S2_sti        in
    S3_sti        in
    S4_sti        in
    S5_sti        in
    S6_sti        in
    S7_sti        in
    Val_A_SUB_sti in
    Val_B_SUB_sti in
	Val_C_SUB_sti in
	Val_D_SUB_sti in
	
	Val_A_port80_sti in
    Val_B_port80_sti in
	Val_C_port80_sti in
	Val_D_port80_sti in
	Val_E_port80_sti in
    Val_F_port80_sti in
	Val_G_port80_sti in
	Val_H_port80_sti in
	Val_I_port80_sti in
    Val_J_port80_sti in

	Val_A_LED_obs out
	Val_B_LED_obs out
	Val_C_LED_obs out

    L0_obs        out
    L1_obs        out
    L2_obs        out
    L3_obs        out
    L4_obs        out
    L5_obs        out
    L6_obs        out
    L7_obs        out
	
    Result_A_SUB_obs  out
    Result_B_SUB_obs  out
	Result_C_SUB_obs  out
    Result_D_SUB_obs  out
	
	Result_A_port80_obs out
	Result_B_port80_obs out
	Result_C_port80_obs out
	Result_D_port80_obs out
	Result_E_port80_obs out
	Result_F_port80_obs out
	Result_G_port80_obs out
	Result_H_port80_obs out
	Result_I_port80_obs out
	Result_J_port80_obs out
	
    Hex0_obs      out
    Hex1_obs      out
    Seg7_a_obs    out
    Seg7_b_obs    out
    Seg7_c_obs    out
    Seg7_d_obs    out
    Seg7_e_obs    out
    Seg7_f_obs    out
    Seg7_g_obs    out
    Horloge_s   internal
  }

  add wave -group Internes
  add wave -group Entr\E9es
  add wave -group Sorties
  add wave -group Internes

  # Add a the waves for each signal in the list
  foreach sigName [lsort -dictionary [array names signalList]] {

    echo $sigName

    set sigType $signalList($sigName)
    if {[string match "in" $sigType]} {
      set groupName Entr\E9es
    } elseif {[string match "out" $sigType]} {
      set groupName Sorties
    } elseif {[string match "inout" $sigType]} {
      set groupName Bidirs
    } elseif {[string match "internal" $sigType]} {
      set groupName Internes
    }
    add wave -expand -group $groupName -noupdate -format Logic -label $sigName /top_sim/$sigName
  }

  add wave -group UUT -divider Inputs
  add wave -group UUT -in "uut/*"
  add wave -group UUT -divider Outputs
  add wave -group UUT -out "uut/*"
  add wave -group UUT -divider Internals
  add wave -group UUT -internal "uut/*"
  add wave -expand -group UUT

  # Configure the wave view
  configure wave -namecolwidth 140
  configure wave -valuecolwidth 80
  WaveRestoreZoom {0 ns} {2600 ns}

  # Restart the simulation (to refresh the wave view)
  restart -f
  wave refresh
}


# --| CONFIGBOARD |-----------------------------------------------------------------------
# --  Configure the board pins and enable the SUBD25 IOs.
# ----------------------------------------------------------------------------------------
proc ConfigBoard {} {
  raise .top
  # Global variables:
  #   - Addresses to configure pins 1 to 16
  #   - Address to enable the SUBD25 IOs
  #   - Address to read the version of the FPGA
  global adrConfPin adrSUBD25OE adrVersion \
		 adr80polesOE adrResetConf adrDataPin
  
  # Read and display the version of the FPGA. Also warn the user to configure the
  # board EMP7128S correctly.
  set FPGAVERSION [LireUSB $adrVersion]
  set ttl "! ATTENTION, RISQUE DE COURT-CIRCUIT !"
  set msg "! ATTENTION, RISQUE DE COURT-CIRCUIT !\n\n\
           Veuillez contr\F4ler que les contraintes des pins de la FPGA aient \E9t\E9 faites \
           correctement.\n Une fois ce contr\F4le effectu\E9, cliquez sur \"OK\".\n\n\
           Console Servo USB, FPGA Version $FPGAVERSION"
  set answer [tk_messageBox -type okcancel -parent .top -default cancel -icon warning -title $ttl -message $msg]
  switch -- $answer {
    cancel QuitConsole
  }

  # Enable the IOs (Line Driver) for SUBD25 and the 80 poles (Valeur \E9crite n'importe pas)
  EcrireUSB $adrSUBD25OE 0
  EcrireUSB $adr80polesOE 0
  
  # Enable du moteur
  EcrireUSB $adrDataPin(En) 1
  
}

# ----------------------------------------------------------------------------------------
# -- Programme principal /////////////////////////////////////////////////////////////////
# ----------------------------------------------------------------------------------------
CheckRunningMode
SetVariables
CreateMainWindow
if {$runningMode == "Simulation"} {
  #ConfigWaves
} else {
  ConfigBoard
}
SetOutputs
