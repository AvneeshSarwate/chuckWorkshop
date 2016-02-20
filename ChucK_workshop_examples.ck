//SECTION 1 - the fundamentals
/*variables, assignment, some primitive tpes, control structures*/

//assignment via the "ChucK" operator
5 => int x;
<<<x, "print!">>>;

//primitive types are int, float, polar, complex, dur, time 

//if statements
if(true){
    <<<"its true">>>;
}
else {
    "nah" => string s;
    <<<s>>>;
}


//for loops
for(0 => int i; i<2; i++) {
    <<<i, "shoop da loop">>>;
}

//while loops
0 => int k;
while(k < 2) {
 <<<k, "one more time">>>;
 k++;   
}

//--------------------------------------------------------------
//--------------------------------------------------------------

//SECTION 2 - built in data structures

//integers are initialized to 0
int ar[1]; 

//syntax for appending to end of array
5 => ar[0];
ar << 20;  

//popBack() removes the last element  
//from the array but does not return it
//the @=> is for assigning by reference 
[1, 5, 6] @=> int ar2[];
ar2.popBack(); 

<<<ar[1], ar2.size()>>>;

//arrays also have a separate namespace for string -> value maps
5 @=> ar["key1"];

<<<ar["key1"], ar["key2"]>>>;

//--------------------------------------------------------------
//-------------------------------------------------------------- 

//SECTION 3 - functions and classes

//free floating, but not first class, functions 
fun float mult(float a, float b){
    return a*b;
}

16 => int num;

class Class1 {
     
     //arbitrary code can run here upon instantiation
     mult(5, 6) => float i; //scope
     <<<"instantiated!">>>;
     
     fun string internalMethod() {
         return "this is a method" + num; //scope 
     }
     
     //what is scope
}
 
Class1 c;

<<<c, c.i, c.internalMethod()>>>;

//--------------------------------------------------------------
//-------------------------------------------------------------- 

//SECTION 4 - time, waiting threads, and events
//4a - basic waiting with time

<<<5>>>;
1::second => now;
<<<6>>>;


now @=> time currentTime; 
<<<7>>>;
currentTime + 1::second => now;
<<<8>>>;

// ----------------------
//4b - waiting on events 

Hid hi;
HidMsg msg;

// try
hi.openMouse(0); 

// infinite time loop
0 => int clickCounter;
while( clickCounter < 3 ){
    
    // wait on event
    hi => now;
    
    // loop over messages
    while( hi.recv( msg )) {
        
        if( msg.isButtonDown() ) {
            <<<"BUTTON DOWN", clickCounter>>>;
            clickCounter++;
        }
    }
}

//--------------------------------------------------------------
//-------------------------------------------------------------- 

//Section 5 - UGens and signal chains

//5a - the simplest single chain
SinOsc s => dac;

s.freq(440);

1::second => now;

s.freq(330);

1::second => now;

s =< dac;

// ----------------------
//5b - a longer signal chain

Saxofony sf => HPF h  => Gain g => dac;

400 => h.freq;

1 => sf.startBlowing;
1::second => now;

0 => g.gain;

100::samp => now;
2000 => h.freq;
100::samp => now;

1=> g.gain;
1::second => now;

//--------------------------------------------------------------
//--------------------------------------------------------------

//SECTION 6 - threading (aka "sporking") 

fun void f1(string s){
    for(0 => int i; i < 5; i++) {
        <<<s, i>>>;
        1::second => now;
    }
}

spork~ f1("uno");

.5::second => now;

spork~ f1("dos");

5::second => now;


//--------------------------------------------------------------
//--------------------------------------------------------------  

//SECTION 7 - deterministic threading example

fun void rec(int n, int depth, int lim) {
    //2::samp => now;
    if(depth > lim) return;
    <<<n>>>;
    /*spork~*/ rec(2*n, depth+1, lim);
    /*spork~*/ rec(2*n+1, depth+1, lim);
    1::samp => now; //me.yield() - see Appendix 1
}

/*spork~*/ rec(1, 1, 4);

//1::samp => now;

//--------------------------------------------------------------
//--------------------------------------------------------------  

//Section 8 - warning - "choking" the processor 

while(true) {
    5 => int x;   
}

SinOsc s => dac;

1::second => now;