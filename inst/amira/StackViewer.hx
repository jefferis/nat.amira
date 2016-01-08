# Amira-Script-Object V3.0
# Coordinate viewing of GHT results
# Set a root directory for the registration
# and a keylist file containing the filestems without the _01.nrrd suffix
# and you should be set.

set myScriptDir ${SCRIPTDIR}

$this proc constructor { } {
    global this
    global myScriptDir
    echo "Script directory is: $myScriptDir"
    $this newPortFilename StackDir
    # Load directory mode
    $this StackDir setMode 3 
    $this StackDir setValue "/Users/jefferis/projects/ChiangReanalysis/ChiangReg/Registration.GHT2"
    
    $this newPortFilename KeyListFile
    set imgdir [$this StackDir getValue]
    $this KeyListFile setValue "$imgdir/"
    
    $this newPortText "FileGlob" 
    $this FileGlob setValue "*.*"
    $this newPortText "RefBrain" 
    $this RefBrain setValue "FCWB"
    
    $this newPortButtonList Action 4
    $this Action setLabel Action:
    $this Action setLabel 0 Rescan
    $this Action setLabel 1 LoadSelected
    $this Action setLabel 2 SaveSelected
    $this Action setLabel 3 ShowSelected
    
    $this newPortIntSlider BrainNum
    $this BrainNum setMinMax 0 0
    $this BrainNum setValue 0
    
    $this newPortInfo BrainName
    $this newPortInfo NumBrains
    $this newPortInfo NumSelBrains
    $this NumSelBrains setValue 0
    
    $this setVar _numBrains 0
    $this setVar _brainList {}
    $this setVar _selectedBrains {}
    $this setVar _refbrain ""

    $this newPortToggleList Selected 1
    $this Selected setLabel "Selected"
    $this Selected setValue 0 0

    $this loadRefBrain
}

$this proc compute {} {
    set numBrains [$this getVar _numBrains]
    if { [ $this StackDir isNew ] } {
        cd [$this StackDir getFilename]
        set imgdir [$this StackDir getValue]
        $this KeyListFile setValue "$imgdir/"
    }
    if { [ $this KeyListFile isNew ] } {
        $this loadKeyFile
        $this initialiseSelection
    }
    if { [ $this BrainNum isNew] && $numBrains } {
        $this show
        $this updateSelectionBox
    }
    if { [ $this Selected isNew] && $numBrains } {
        $this updateSelection
    }
    if { [ $this RefBrain isNew] } {
        $this loadRefBrain
    }
    if { [ $this Action isNew] } {
        if {[$this Action getValue] == 0} {
            $this loadKeyFile
        }
        if {[$this Action getValue] == 1} {
            $this loadSelectedBrainList
        }
        if {[$this Action getValue] == 2} {
            $this saveSelectedBrainList
        }
        if {[$this Action getValue] == 3} {
            echo [$this makeSelectedBrainList]
        }
        
    }
}

$this proc show {} {
    $this loadCurrentBrain
    $this BrainName setValue [$this currentBrainName]
    viewer 0 redraw
}

$this proc currentBrain {} {
    $this BrainNum getValue
}

$this proc currentBrainName {} {
    set i [ $this currentBrain ]
    lindex [$this getVar _brainList] $i
}

$this proc loadKeyFile {} {

    set filename [$this KeyListFile getFilename]
    if { [file isdirectory $filename]} {
        echo "Key file $filename is a directory!"
        set brainList [lsort [glob [$this FileGlob getValue] ] ]
    } else {
        if { [file exists $filename]} {
            echo "Key file $filename exists!"
            set brainList [$this loadBrainList $filename]
        } else {
            set brainList ""
        }
    }
    set numBrains [llength $brainList]

    if { $numBrains > 0} {
        $this BrainNum setMinMax 0 [expr $numBrains - 1]
        $this NumBrains setValue $numBrains
        $this setVar _numBrains $numBrains
        $this setVar _brainList $brainList
        $this initialiseSelection
    }
}

$this proc makeAnimate {} {
    create HxDynamicParameter {Animate}
    Animate object connect $this
    Animate time setMinMax 0 [$this BrainNum getMaxValue]
    Animate time setSubMinMax 0 [$this BrainNum getMaxValue]
    # Animate time setValue 62
    Animate time setDiscrete 1
    Animate time setIncrement 1
    Animate time animationMode -once
    Animate fire
    Animate port setIndex 0 0
    Animate fire
    Animate value setState {t}
    Animate time setValue [$this BrainNum getValue]
    Animate fire
    Animate setViewerMask 16383
    Animate select
    Animate setPickable 1
}

# _selected Brains is a list of 1s and 0s
$this proc updateSelection {} {
    set selectedBrains [$this getVar _selectedBrains]
    set cb [$this currentBrain]
    set boxstate [$this Selected getValue 0]
    # echo "cb = $cb and boxstate = $boxstate"
    lset selectedBrains $cb $boxstate
    $this setVar _selectedBrains $selectedBrains
    $this updateNumSelectedBrains
}

$this proc updateNumSelectedBrains {} {
    set numselbrains [$this numSelectedBrains]
    $this NumSelBrains setValue $numselbrains
}

$this proc updateSelectionBox {} {
    set selectedTF [lindex [$this getVar _selectedBrains] [$this currentBrain]]
    $this Selected setValue 0 $selectedTF
}

$this proc initialiseSelection {} {
    echo "Initialising selection!"
    set numBrains [$this getVar _numBrains]
    set out {}
    for {set i 0} {$i < $numBrains} {incr i} {lappend out 0}
    $this setVar _selectedBrains $out
}

$this proc numSelectedBrains {} {
    set numBrains [$this getVar _numBrains]
    set selectedBrains [$this getVar _selectedBrains]
    
    set numSelectedBrains 0
    for {set i 0} {$i < $numBrains} {incr i} {
        if { [lindex $selectedBrains $i] > 0} {
            # append ith brain name
            incr numSelectedBrains
        }
    }
    return $numSelectedBrains
}

$this proc makeSelectedBrainList {} {
    set numBrains [$this getVar _numBrains]
    set selectedBrains [$this getVar _selectedBrains]
    set brainList [$this getVar _brainList]
    
    set out {}
    for {set i 0} {$i < $numBrains} {incr i} {
        if { [lindex $selectedBrains $i] > 0} {
            # append ith brain name
            set cb [lindex $brainList $i]
            lappend out $cb
        }
    }
    return $out
}

$this proc saveSelectedBrainList {} {
    set selbrains [$this makeSelectedBrainList]

    set klf [$this KeyListFile getValue]
    set klfroot [file rootname $klf]
    set sklf "${klfroot}sel.txt"
    # if selection file already exists, move existing file aside as a backup
    if { [file exists $sklf] } {
        file rename -force $sklf "$sklf.bak"
    }
    $this writeTextFile $sklf $selbrains
}

$this proc writeTextFile { filename text } {
    set fileId [open $filename "w"]
    
    foreach line $text {
        echo $line
        puts $fileId $line
    }
    close $fileId
}

$this proc loadSelectedBrainList {} {
    set klf [$this KeyListFile getFilename]
    set klfroot [file rootname $klf]
    set sklf "${klfroot}sel.txt"
    if { [file exists $sklf]} {
        echo "Loading selection file $sklf!"
        set selectedBrainList [$this loadBrainList $sklf]
        set numBrains [llength $selectedBrainList]
        
        if { $numBrains > 0} {
            # set selection list to all 1s
            $this initialiseSelection
            set brainList [$this getVar _brainList]
            set selectedBrains [$this getVar _selectedBrains]
            
            foreach brain $selectedBrainList {
                set idx [lsearch -exact $brainList $brain]
                if { $idx > -1 } {
                    lset selectedBrains $idx 1
                } else {
                    echo "Couldn't find $brain amongst loaded brains"
                }
            }
            
            $this setVar _selectedBrains $selectedBrains
        }
    }
    $this updateNumSelectedBrains
}

$this proc loadBrainList { filename } {
    # load generic text file, returning list with non-empty lines
    # that do not begin with a hash
    set brainList {}
    if { [ catch {set fp [open $filename r]}]} {
        echo "unable to open $filename"
        return $brainList
    }
    set file_data [read $fp]
    close $fp
    set data [split $file_data "\n"]

    # include non-empty lines that do not begin with #
    foreach line $data {
        if {[string length $line] > 0 && 
            [string compare -length 1 $line "#"] != 0 } {
                lappend brainList $line
            }
    }
    return $brainList
}

$this proc dirForCurrentBrain { } {
	set brainkey [$this currentBrainName]
	set imgdir [$this StackDir getValue]
	return $imgdir
}

$this proc loadRefBrain { } {
	set refbrain [$this getVar _refbrain]
    # First clean up any existing brains
    if {[exists refbrainsurfview] } {
		remove refbrainsurfview
	}
    if {[exists $refbrain] } {
		remove $refbrain
	}
	
    global myScriptDir
    set refbrain [$this RefBrain getValue]
    set refbrainsurf "${refbrain}.surf"
    set refbrainpath [file join [file dirname $myScriptDir] "hx/${refbrainsurf}"]
    if {[exists $refbrainsurf] } {
		remove $refbrainsurf
	}
	echo "Loading ref brain $refbrainsurf"
	set refbrain [load $refbrainpath]
	create HxDisplaySurface {refbrainsurfview}
	refbrainsurfview data connect $refbrain
	refbrainsurfview colormap setDefaultColor 1 0.1 0.1
	refbrainsurfview colormap setDefaultAlpha 0.500000
	refbrainsurfview colormap setLocalRange 0
	refbrainsurfview fire
	set LINES 2
	refbrainsurfview drawStyle setValue $LINES
	refbrainsurfview fire
	$this setVar _refbrain $refbrain
}

$this proc makeVoltex { } {
	if {[exists "curbrainview"]} {
		curbrainview data disconnect
	} else {
		create HxVoltex {curbrainview}
		curbrainview colormap setDefaultColor 1 0.1 0.1
		curbrainview colormap setDefaultAlpha 0.500000
		curbrainview texture2D3D setValue 1
		curbrainview slices setValue 256
		curbrainview colormap setLocalRange 0
		curbrainview fire
	}
}

$this proc loadCurrentBrain { } {
	set dirname [$this dirForCurrentBrain]
	# standard path to low res version of original (unregistered) sample image
	set filename [file join $dirname [$this currentBrainName] ]
	
	# figure out which (if any) of the downsampled images are available
	# echo $filename
	set filewewant ""
	if { [file exists $filename]==0 } {
		echo "No image data for current brain at: $filename"
	}

	# load the first available resampled image (will prefer lowres.am if available)
	if { [string length filename]>0 } {
		# first load voltex
		# or disconnect if it already exists
		$this makeVoltex
		# then load data
		if {[exists curbrain] } {
			remove curbrain
		}
		
		[load $filename] setLabel "curbrain"
		# ... and connect and fire
		curbrainview data connect "curbrain"
		
		# set the display range for the voltex viewer
		set mymax [lindex [curbrain getRange ] 1]
		set mymin [expr {$mymax / 20}]
		curbrainview colormap setMinMax  $mymin $mymax
		
		curbrainview doIt hit
		curbrainview fire
	}
}
