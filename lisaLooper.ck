Hid hi;
HidMsg msg;

// which keyboard
0 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

// open keyboard (get device number from command line)
if( !hi.openKeyboard( device ) ) me.exit();
<<< "keyboard '" + hi.name() + "' ready", "" >>>;




// which mouse
0 => device;
// get from command line 
if( me.args() ) me.arg(0) => Std.atoi => device;
 
// hid objects
Hid hi2;    
HidMsg msg2;

// try
if( !hi2.openMouse( device ) ) me.exit();
<<< "mouse '" + hi2.name() + "' ready...", "" >>>;





adc => LiSa lisa  =>PitShift ps /*  => Modulate mod => DelayL del => */ => dac;
10::second => dur maxBuff => lisa.duration;
1 => lisa.loop;
0 => ps.mix;
1 => ps.shift;  


int xy[2];
float fdata;
0 => int x;
0 => int y;
fun void getMouseDelta(Hid mouse, HidMsg mesg) {
    while(true) {
        mouse => now;
        while(mouse.recv( mesg)) {
            
            if(mesg.isMouseMotion()) {
                //int xy[2];
                mesg.deltaX => xy[0];
                mesg.deltaY => xy[1];
                x + xy[0] => x;
                y + xy[0] => y;
                mesg.fdata => fdata;
                //return xy;     
            }            
        } 
    }   
} 

0 => int play;

fun void keyBoardListener() {
    // infinite event loop
    now => time recStart;
    0 => int recording;
    1 => int loop;
    0::second => dur playPos;
    dur playPosAr[10];
    0 => int jumpSetFlag;
    
    while( true )
    {
        // wait on event
        hi => now;
        // get one or more messages
        while( hi.recv( msg ) )
        {
            // check for action type
            if( msg.isButtonDown() )
            {
                <<< "down:", msg.which, "(code)", msg.key, "(usb key)", msg.ascii, "(ascii)" >>>;
                if(msg.which == 44){
                    if(!recording){
                        loopRecStart(lisa) => recStart;
                        !recording => recording;
                        <<<"RECCORDING">>>;
                    }
                    else if(now-recStart < maxBuff){
                        loopStopRecAndPlay(lisa, recStart);
                        !recording => recording;
                        <<<"DONE">>>;
                        //<<<recording>>>;
                        //<<<lisa.rate()>>>;
                    }
                    //<<<fdata, xy[0], xy[1]>>>;
                    continue;
                }
                //if(msg.which == SOMETHING) 0 => lisa.play;
                //if(msg.which == SOMELSE) 1 => lisa.play;
                if(msg.which == 40) !play => play => lisa.play; //enter key - start and stop play
                if(msg.which == 52) 0::second => lisa.playPos; //apostrophe - jump to beginning 
                if(msg.which == 229) !loop => loop => lisa.loop; //right shift - start/stop looping
                if(msg.which == 20) liSaRateCont(hi, msg, lisa, 20); //hold down q - control play rate with mouse
                if(msg.which == 26) pitchShift(hi, msg, ps, 26); //hold down w - control pitch shift pitch wiht mouse
                if(msg.which == 8) pitchMix(hi, msg, ps, 8); //hold down e - control pitch shift mix with mouse
                if(msg.which == 55) lisa.rate() * 2 => lisa.rate; // > - double the play speed
                if(msg.which == 54) lisa.rate() / 2 => lisa.rate; // < - half the play speed 
                
                //hold down left shift and press a number key to set a jump point
                //press the number key to jump to that point
                if(msg.which == 225) 1 => jumpSetFlag;
                for(30 => int i; i < 40; i++) {
                    if(msg.which == i && jumpSetFlag) lisa.playPos() => playPosAr[i-30];
                    if(msg.which == i && !jumpSetFlag) playPosAr[i-30] => lisa.playPos;
                }            
                
            }
            
            else
            {
                //<<< "up:", msg.which, "(code)", msg.key, "(usb key)", msg.ascii, "(ascii)" >>>;
                if(msg.which == 225) 0 => jumpSetFlag;  
            }
        }
    }
}



spork ~ keyBoardListener();
spork ~ getMouseDelta(hi2, msg2);

while(true) {
    1::second => now;
}




fun void liSaRate(LiSa lis, float rate) {
    rate => lisa.rate;   
}

fun void liSaRateCont(Hid keyboard, HidMsg mesg, LiSa lis, int button) {
    // wait on event
    1 => int flag;
    
    while(flag) {
        //keyboard => now;
        .01::second => now;
        if(.05 + (fdata * 5) != lis.rate()) {
            .05 + (fdata * 5) => lis.rate;
            <<<lis.rate(), "listrate", button>>>;
        }
        // get one or more messages
        while( keyboard.recv( mesg ) )
        {
            if( !mesg.isButtonDown()  && mesg.which == button)
            {
                return;
            }
        }
    }
}

fun void pitchShift(Hid keyboard, HidMsg mesg, PitShift ps, int button) {
    // wait on event
    1 => int flag;
    
    while(flag) {
        //keyboard => now;
        .01::second => now;
        if(.2 + (fdata * 10) != ps.shift()){
            .2 + (fdata * 10) => ps.shift;
            <<<ps.shift(), "pitch-shift", button>>>;
        }
        // get one or more messages
        while( keyboard.recv( mesg ) )
        {
            if( !mesg.isButtonDown()  && mesg.which == button)
            {
                return;  
            }
        }
    }
}

fun void pitchMix(Hid keyboard, HidMsg mesg, PitShift ps, int button) {
    // wait on event
    1 => int flag;
    
    while(flag) {
        //keyboard => now;
        .01::second => now;
        if(fdata != ps.mix()){
            fdata => ps.mix;
            <<<ps.mix(), "pitch-mix", button>>>;
        }
        // get one or more messages
        while( keyboard.recv( mesg ) )
        {
            if( !mesg.isButtonDown()  && mesg.which == button)
            {
                return;
            }
        }
    }
}
     
fun time loopRecStart(LiSa lis) {
    
    0 => play => lis.play; 
    lis.clear();
    0::second => lis.recPos;
    1 => lis.record;
    0::second => lis.loopStart;
    0::second => lis.playPos;
    1 => lis.rate;
    return now;
}


fun void loopStopRecAndPlay(LiSa lis, time recStart) {
 
    0 => lis.record;
    now - recStart => lis.loopEnd;
    1 => play => lis.play;
}

//ADD A LOOP POINT SETTER
//press a key and loop start (for loop resetting via \’) starts
//at that point instead of at position 0
/* be able to set muliple points
hold shift and press a number to save that point
press just the number to play from that point
*/

//GAIN CONTROL


//BUG? - can’t stop playing right after recording 

//create MOUSE object that encapsulates listener and easy data access 
/*have a thread listening and updating an array that can always
be read from*/

/* create a stack/history structure for incoming messages in general 
so that you can either read them as they come in (live) or access 
them as you like without losing them (historied data structures?)*/

           