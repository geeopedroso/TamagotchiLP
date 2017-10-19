use warnings;
use strict;

use Wx;
use wxPerl::Constructors;
use Wx qw( wxWidth wxHeight);
use threads('yield', 'stack_size'=>64*4096, 'exit'=> 'threads_only', 'stringify');
use threads::shared;
#use Wx::Image;
#use Wx::Perl::Imagick;
#use GD::Image;
use IO::File;
use GD::Image;



package MyApp;
  
use base 'Wx::App';

my $btnSleep :shared;
$btnSleep = 'DORMIR';

my $lastState :shared;

my $happy :shared;
$happy = 100;

my $hunger :shared;
$hunger = 100;

my $health :shared;
$health = 100;

my $dirty :shared;
$dirty = 0;

my $tired :shared;
$tired = 0;

my $luz :shared;
$luz = 'ACESA';

my $state :shared; 
$state = 'normal';

my $normal = "
     (o)--(o)
    /.____.\\
    \\_____/
   ./          \\.
( .              . )
  \\ \\_\\\\//_/ /
 ~~  ~~  ~~  
 ";

sub Restart {
   $state = 'normal';
   $happy = 100;
   $hunger = 100;
   $health = 100;
   $tired = 0;
   $dirty = 0;
   $luz = 'ACESA';
   $btnSleep = 'DORMIR';
}

sub UpdateTime {
   if ($state eq 'normal') {
	$happy = $happy - 1;
	$hunger = $hunger - 1;
	$health = $health - 1;
	$tired++;
	$dirty++;
	
   }
   if ($state eq 'sad') {
	$happy = $happy - 3;
	$hunger = $hunger - 1;
	$health = $health - 2;
	$tired++;
	$dirty++;
   }
   if ($state eq 'sick') {
	$happy = $happy - 1;
	$hunger = $hunger - 2;
	$health = $health - 3;
	$tired++;
	$dirty++;
   }
   if ($state eq 'hungry') {
	$happy = $happy - 2;
	$hunger = $hunger - 3;
	$health = $health - 2;
	$tired++;
	$dirty++;
   }
   if ($state eq 'tired') {
	$happy = $happy - 3;
	$hunger = $hunger - 1;
	$health = $health - 2;
	$tired++;
	$dirty++;
   }
   if($state eq 'sleeping'){
	$happy = $happy - 1;
	$hunger = $hunger - 1;
	$health = $health - 1;
	$tired = $tired - 2;
	$dirty++;
	if($tired <= 0){
           $state = $lastState;
           $luz = 'ACESA';
           $btnSleep = 'DORMIR';
        }
   }
   Update();
}

sub Update {
      if($state ne 'dead' and $state ne 'sleeping'){
		if($hunger <= 0 or $happy <= 0 or $health <= 0){
			$state = 'dead';
		}
		elsif($state eq 'normal'){
			if($dirty >= 10 and $state ne 'dirty'){
				$state = 'dirty';
			}
			elsif($tired >= 50 and $state ne 'tired'){
				$state = 'tired';
			}
			elsif($happy < 40 and $state ne 'sad'){ 
				$state = 'sad';	
			}
			elsif($health < 40 and $state ne 'sick'){ 
				$state = 'sick';
			}
			elsif($hunger < 40 and $state ne 'hungry'){
				$state = 'hungry';
			}
		}
		elsif($state eq 'dirty' and $dirty < 10){
			if(($happy >= 40 and $health >= 40 and $hunger >= 40) and ($state ne 'normal')){
				$state = 'normal';
			}
			elsif($tired >= 50 and $state ne 'tired'){
				$state = 'tired';
			}
			elsif($happy < 40 and $state != 'sad'){ 
				$state = 'sad';
			}
			elsif($health < 40 and $state ne 'sick'){ 
				$state = 'sick';
			}
			elsif($hunger < 40 and $state ne 'hungry'){
				$state = 'hungry';
			}
		}
		elsif($state eq 'tired' and $tired < 50){
			if($dirty >= 50 and $state ne 'dirty'){
				$state = 'dirty';
			}
			elsif(($happy >= 40 and $health >= 40 and $hunger >= 40) and ($state ne 'normal')){
				$state = 'normal';
			}
			elsif($happy < 40 and $state ne 'sad'){ 
				$state = 'sad';
			}
			elsif($health < 40 and $state ne 'sick'){ 
				$state = 'sick';
			}
			elsif($hunger < 40 and $state ne 'hungry'){
				$state = 'hungry';
			}
		}
		elsif($state eq 'sad'){
			if($dirty >= 50 and $state ne 'dirty'){
				$state = 'dirty';
			}
			elsif(($happy >= 90 and $health >= 40 and $hunger >= 40) and ($state ne 'normal')){
				$state = 'normal';
			}
			elsif($tired >= 50 and $state ne 'tired'){
				$state = 'tired';
			}
			elsif($health < 40 and $state ne 'sick'){ 
				$state = 'sick';
			}
			elsif($hunger < 40 and $state ne 'hungry'){
				$state = 'hungry';
			}
		}
		elsif($state eq 'sick'){
			if($dirty >= 50 and $state ne 'dirty'){
				$state = 'dirty';
			}
			elsif(($happy >= 40 and $health >= 40 and $hunger >= 40) and ($state ne 'normal')){
				$state = 'normal';
			}
			elsif($happy < 40 and $state ne 'sad'){ 
				$state = 'sad';
			}
			elsif($tired >= 50 and $state ne 'tired'){
				$state = 'tired';
			}
			elsif($hunger < 40 and $state ne 'hungry'){
				$state = 'hungry';
			}
		}
		elsif($state eq 'hungry'){
			if($dirty >= 50 and $state ne 'dirty'){
				$state = 'dirty';
			}
			elsif(($happy >= 40 and $health >= 40 and $hunger >= 40) and ($state ne 'normal')){
				$state = 'normal';
			}
			elsif($happy < 40 and $state ne 'sad'){ 
				$state = 'sad';
			}
			elsif($tired >= 50 and $state ne 'tired'){
				$state = 'tired';
			}
			elsif($health < 40 and $state ne 'sick'){ 
				$state = 'sick';
			}
		}
	}
	elsif($state ne 'dead' and $luz eq 'ACESA'){
            $state = $lastState;
	}
}

sub OnInit {
        my $self = shift;
        my $frame = wxPerl::Frame->new(undef, 'A wxPerl Application');
        $frame->SetMinSize([120,40]);
        my $sizer = Wx::BoxSizer->new(&Wx::wxVERTICAL);
        
        my $text_tama = Wx::StaticText->new(
           $frame,             # parent window
           -1,                 # Let the system assign a window ID
           "$normal",    # The literal text to display
           [150, 150],           # [x, y] coordinates of the control
        );
        
        my $text_happy = Wx::StaticText->new(
           $frame,             # parent window
           -1,                 # Let the system assign a window ID
           "HAPPY",    # The literal text to display
           [50, 25],           # [x, y] coordinates of the control
        );
        
        my $text_happy_value = Wx::StaticText->new(
           $frame,             # parent window
           1,                 # Let the system assign a window ID
           "| $happy |",    # The literal text to display
           [50, 45],           # [x, y] coordinates of the control
        );
        
        my $text_hunger = Wx::StaticText->new(
           $frame,             # parent window
           -1,                 # Let the system assign a window ID
           "HUNGER",    # The literal text to display
           [120, 25],           # [x, y] coordinates of the control
        );
        
        my $text_hunger_value = Wx::StaticText->new(
           $frame,             # parent window
           -1,                 # Let the system assign a window ID
           "| $hunger |",    # The literal text to display
           [120, 45],           # [x, y] coordinates of the control
        );
        
        my $text_health = Wx::StaticText->new(
           $frame,             # parent window
           -1,                 # Let the system assign a window ID
           "HEALTH",    # The literal text to display
           [190, 25],           # [x, y] coordinates of the control
        );
        
        my $text_health_value = Wx::StaticText->new(
           $frame,             # parent window
           -1,                 # Let the system assign a window ID
           "| $health |",    # The literal text to display
           [190, 45],           # [x, y] coordinates of the control
        );
        
        my $text_state = Wx::StaticText->new(
           $frame,             # parent window
           -1,                 # Let the system assign a window ID
           "STATE",    # The literal text to display
           [260, 25],           # [x, y] coordinates of the control
        );
        
        my $text_state_value = Wx::StaticText->new(
           $frame,             # parent window
           -1,                 # Let the system assign a window ID
           "| $state |",    # The literal text to display
           [260, 45],           # [x, y] coordinates of the control
        );
        
        my $text_luz = Wx::StaticText->new(
           $frame,             # parent window
           -1,                 # Let the system assign a window ID
           "LUZ: ",    # The literal text to display
           [10, 90],           # [x, y] coordinates of the control
        );
        
        my $text_luz_value = Wx::StaticText->new(
           $frame,             # parent window
           -1,                 # Let the system assign a window ID
           "$luz",    # The literal text to display
           [40, 90],           # [x, y] coordinates of the control
        );
        
        my $comer = Wx::Button->new( $frame,        # parent window
                                  -1,             # ID
                                  'COMER',      # label
                                  [100, 300],       # position
                                  [-1, -1],       # default size
                                  );
                                  
  
       #my $button = wxPerl::Button->new($frame, 'Click Me'); 
       #$sizer->Add($button, 0.5, 5, &Wx::wxEXPAND);
       #my $button2 = wxPerl::Button->new($frame, 'DO NOT CLICK');
       #$sizer->Add($button2, 0.5, 5, &Wx::wxEXPAND);
       
       
       
       my $limpar = Wx::Button->new( $frame,        # parent window
                                  -1,             # ID
                                  'LIMPAR',      # label
                                  [100, 330],       # position
                                  [-1, -1],       # default size
                                  );
                                  
       my $jogar = Wx::Button->new( $frame,        # parent window
                                  -1,             # ID
                                  'JOGAR',      # label
                                  [100, 360],       # position
                                  [-1, -1],       # default size
                                  );
       
       
       
       my $curar = Wx::Button->new( $frame,        # parent window
                                  -1,             # ID
                                  'CURAR',      # label
                                  [190, 300],       # position
                                  [-1, -1],       # default size
                                  );
       
       my $dormir = Wx::Button->new( $frame,        # parent window
                                  -1,             # ID
                                  "$btnSleep",      # label
                                  [190, 330],       # position
                                  [-1, -1],       # default size
                                  );
       
       my $reset = Wx::Button->new( $frame,        # parent window
                                  -1,             # ID
                                  'RESTART',      # label
                                  [190, 360],       # position
                                  [-1, -1],       # default size
                                  );
       
       Wx::Event::EVT_BUTTON($jogar, -1, sub {
                lock$happy;
                $happy = $happy + 2;
                lock$hunger;
                $hunger = $hunger - 2;
                $tired = $tired + 2;
                $text_happy_value->SetLabel("| $happy |");
                $text_hunger_value->SetLabel("| $hunger |");
                });
                
      Wx::Event::EVT_BUTTON($curar, -1, sub {
                lock$health;
                $health = $health + 2;
                $text_health_value->SetLabel("| $health |");
                });
                
       Wx::Event::EVT_BUTTON($comer, -1, sub {
                lock$hunger;
                $hunger = $hunger + 2;
                $text_hunger_value->SetLabel("| $hunger |");
                });
                
       Wx::Event::EVT_BUTTON($limpar, -1, sub {
                lock$dirty;
                $dirty = 0;
                Update();
                $text_state_value->SetLabel("| $state |"); 
                });
                
       Wx::Event::EVT_BUTTON($reset, -1, sub {
                Restart(); 
               $text_luz_value->SetLabel("$luz");
               $dormir->SetLabel("$btnSleep");
               $text_happy_value->SetLabel("| $happy |");
               $text_hunger_value->SetLabel("| $hunger |");
               $text_health_value->SetLabel("| $health |");
               $text_state_value->SetLabel("| $state |");
                });
                
       Wx::Event::EVT_BUTTON($dormir, -1, sub {
                if($luz eq 'ACESA'){
                     $luz = 'APAGADA';
                     $btnSleep = 'ACORDAR';
                     $lastState = $state;
                     $state = 'sleeping';
                }
                else{
                     $luz = 'ACESA';
                     $btnSleep = 'DORMIR';
                }
                Update();
                $text_luz_value->SetLabel("$luz");
                $dormir->SetLabel("$btnSleep");
                $text_state_value->SetLabel("| $state |"); 
                });
                
       my $tr_listener = threads->create(sub{
            while(1){
               sleep 2;
               UpdateTime();
               print "dirty: $dirty\n tired: $tired\n";
               $text_luz_value->SetLabel("$luz");
               $dormir->SetLabel("$btnSleep");
               $text_happy_value->SetLabel("| $happy |");
               $text_hunger_value->SetLabel("| $hunger |");
               $text_health_value->SetLabel("| $health |");
               $text_state_value->SetLabel("| $state |");
            }
       });
       
       
       
       
       $frame->SetSizer($sizer);
       $frame->Show;
       #$frame->Freeze();
       #$frame->DestroyChildren();
       
}
 
MyApp->new->MainLoop;