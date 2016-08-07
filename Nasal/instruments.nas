# set the timer for the selected function

var UPDATE_PERIOD = 0;
var freq = 0;
var formatted = 0;

var digit1 = 0;
var digit2 = 0;
var digit3 = 0;
var digit4 = 0;
var digit5 = 0;

var gps_display = [];

var instrumenttimer = func {
    settimer(func {
        radiodisplay();
	instrumenttimer()
    }, UPDATE_PERIOD);
}

# =============================== end timer stuff ===========================================

# ==================== Radio Frequency Display =========================
var displaysegments = func (radio, selected) {
    var freq=getprop("/instrumentation/"~radio~"/frequencies/"~selected~"-mhz");
    var formatted=sprintf("%.02f",freq);

    digit1=substr(formatted,0,1);
    digit2=substr(formatted,1,1);
    digit3=substr(formatted,2,1);
    digit4=substr(formatted,4,1);
    digit5=substr(formatted,5,1);

    setprop("instrumentation/"~radio~"/"~selected~"/digit1",digit1);
    setprop("instrumentation/"~radio~"/"~selected~"/digit2",digit2);
    setprop("instrumentation/"~radio~"/"~selected~"/digit3",digit3);
    setprop("instrumentation/"~radio~"/"~selected~"/digit4",digit4);
    setprop("instrumentation/"~radio~"/"~selected~"/digit5",digit5);
}

var radiodisplay = func() {
    displaysegments ("nav[0]", "selected");
    displaysegments ("nav[0]", "standby");

    displaysegments ("comm[0]", "selected");
    displaysegments ("comm[0]", "standby");

    displaysegments ("comm[1]", "selected");
    displaysegments ("comm[1]", "standby");
}

####################### Initialise ##############################################

initialize = func {

    ### Initialise Radios ###
    props.globals.getNode("/instrumentation/uhf/commvol-norm", 1).setDoubleValue(0.0);
    props.globals.getNode("/instrumentation/kns80/navvol-norm", 1).setDoubleValue(0.0);
    props.globals.getNode("/instrumentation/kx155a/commvol-norm", 1).setDoubleValue(0.0);
    props.globals.getNode("/instrumentation/kx155a/navvol-norm", 1).setDoubleValue(0.0);
    props.globals.getNode("/instrumentation/transponder/inputs/knob-mode", 1).setDoubleValue(0);
    props.globals.getNode("/instrumentation/dme/switch-position", 1).setDoubleValue(0);
    props.globals.getNode("/instrumentation/fric-knob", 1).setDoubleValue(0.01);

    instrumenttimer();
    # Finished Initialising
    print ("Instruments : initialised");
    var initialized = 1;

} #end func

######################### Fire it up ############################################
setlistener("/sim/signals/fdm-initialized",initialize);

######################### CANOPY PARAMETOR ##########################################
#splash
setlistener("/engines/engine[0]/rpm",func{
             interpolate("/environment/aircraft-effects/splash-vector-x",getprop("/engines/engine[0]/rpm")*0.005+getprop("/velocities/airspeed-kt")*0.005,1)});
props.globals.getNode("/environment/aircraft-effects/splash-vector-y", 0).setIntValue(0.01);
props.globals.getNode("/environment/aircraft-effects/splash-vector-z", 0).setIntValue(-1);

#TAT

setlistener("/engines/engine[0]/rpm",func{
             interpolate("/environment/total-air-temperature-degc",getprop("/environment/temperature-degc")+ ((getprop("/environment/temperature-degc")+ 273) * 0.2 * (getprop("/velocities/mach") * getprop("/velocities/mach"))),5)});

#frost
setprop("/environment/windowheat-level", 1);
setlistener("/engines/engine[0]/rpm",func{
             interpolate("/environment/aircraft-effects/frost-level",(getprop("/environment/total-air-temperature-degc")+10)*getprop("/environment/windowheat-level")*-0.03,1)});
setlistener("/controls/anti-ice/window-heat",func{
             interpolate("/environment/windowheat-level",1-getprop("/controls/anti-ice/window-heat")*0.9,10)});


