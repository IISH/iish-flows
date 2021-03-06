<?php
set_time_limit(60); //GIVE THE SCRIPT A LIMIT OF 60 SECONDS TO RUN
#ini_set("memory_limit", "2048M"); //SET THE MEMORY LIMIT TO 2Mb


//DEFINE DIFERENT DERIVATIVE TYPES
$derivativeTypes = array();

//MULTIDIMENSIONAL ARRAY WITH ALL DERIVATIVE TYPES

// 'encode' AND 'extension' ARE THE ONLY MANDATORY VALUES - FOR THE VALUES OF 'encode' RUN 'convert -list compress'
// IF YOU DEFINE 'targetDPI' THEN 'higher', 'lower' AND 'target' ARE MANDATORY
// ['targetDPI'][n]['target'] ACCEPTS INT VALUES AND 2 STRINGS : 'equal' AND 'half'

// 'maxWidth' AND 'maxHeight' OVERRIDE 'targetDPI' RULES BUT DOES THE RESIZE BASED ON DPIS - PXS VALUES WILL NOT PRECISE (BECAUSE OF THE FLOOR ON DPIS) BUT ALWAYS LOWER THEN THE DEFINED 'maxWidth' AND 'maxHeight'

// 'forceWidth' OVERRIDE ALL OTHER RESIZE OPTIONS AND SHOULD ONLY BE USED FOR GENERANTING THUMBS D3 - RESIZE IS NOT BASED ON DPIS (DPIS ARE DEFAULTED TO 72)


//D1
$derivativeTypes['level1']['encode'] = 'JPEG';
$derivativeTypes['level1']['extension'] = 'jpg';
$derivativeTypes['level1']['quality'] = 45;


//D2
/*$derivativeTypes['d2']['targetDPI'][0]['higher'] = 0;
$derivativeTypes['d2']['targetDPI'][0]['lower'] = 200;
$derivativeTypes['d2']['targetDPI'][0]['target'] = 'equal';

$derivativeTypes['d2']['targetDPI'][1]['higher'] = 200;
$derivativeTypes['d2']['targetDPI'][1]['lower'] = 400;
$derivativeTypes['d2']['targetDPI'][1]['target'] = 200;

$derivativeTypes['d2']['targetDPI'][2]['higher'] = 400;
$derivativeTypes['d2']['targetDPI'][2]['lower'] = 99999;
$derivativeTypes['d2']['targetDPI'][2]['target'] = 'half';

$derivativeTypes['d2']['encode'] = 'JPEG';
$derivativeTypes['d2']['extension'] = 'jpg';
$derivativeTypes['d2']['quality'] = 35;*/


//D2 OSA
$derivativeTypes['level2']['targetDPI'][0]['higher'] = 0;
$derivativeTypes['level2']['targetDPI'][0]['lower'] = 200;
$derivativeTypes['level2']['targetDPI'][0]['target'] = 'equal';

$derivativeTypes['level2']['targetDPI'][1]['higher'] = 200;
$derivativeTypes['level2']['targetDPI'][1]['lower'] = 400;
$derivativeTypes['level2']['targetDPI'][1]['target'] = 200;

$derivativeTypes['level2']['targetDPI'][2]['higher'] = 400;
$derivativeTypes['level2']['targetDPI'][2]['lower'] = 99999;
$derivativeTypes['level2']['targetDPI'][2]['target'] = 'half';

$derivativeTypes['level2']['minWidth'] = 600; // PX
$derivativeTypes['level2']['minHeight'] = 600; // PX

$derivativeTypes['level2']['maxWidth'] = 1500; //PX
$derivativeTypes['level2']['maxHeight'] = 1500; //PX

$derivativeTypes['level2']['encode'] = 'JPEG';
$derivativeTypes['level2']['extension'] = 'jpg';
$derivativeTypes['level2']['quality'] = 75;


//D3
$derivativeTypes['level3']['encode'] = 'JPEG';
$derivativeTypes['level3']['extension'] = 'jpg';
$derivativeTypes['level3']['quality'] = 25;
$derivativeTypes['level3']['forceWidth'] = 200; //PX

function getImageResolution($a)
{
    $split = explode(' ', $a);
    return $split[0];
}

function getImageUnits($a)
{
    $split = explode(' ', $a);
    if (sizeof($split) != 0 && $split[1] == 'PixelsPerCentimeter') return 2;
    return 1;
}

function getGeometry($a)
{
    $split = explode(' ', $a);
    if (sizeof($split) == 0) return $a;
    return $split[0];
}

function generateDerivative($input, $output, $derivativeType, $width, $height, $xresolution, $yresolution, $depth)
{
    global $derivativeTypes;

    $original['dpis']['x'] = getImageResolution($xresolution);
    $original['dpis']['y'] = getImageResolution($yresolution);
    $original['dpisUnit'] = getImageUnits($xresolution);

    if ($original['dpisUnit'] == 2) {
        $original['dpis'] = (int)round($original['dpis']['x'] * 2.54237);
    } else {
        $original['dpis'] = (int)$original['dpis']['x'];
    }

    $original['depth'] = $depth;
    $targetDPIs = $original['dpis'];
    $targetWidth = $original['px']['width'] = getGeometry($width);
    $targetHeight = $original['px']['height'] = getGeometry($height);

    //PARSE DPIs RULES
    if (isset($derivativeTypes[$derivativeType]['targetDPI'])) {

        foreach ($derivativeTypes[$derivativeType]['targetDPI'] as $key => $value) {

            if ($original['dpis'] > $value['higher'] && $original['dpis'] <= $value['lower']) {

                if ($value['target'] == 'half') {
                    $targetDPIs = (int)round($original['dpis'] / 2);
                }

                if ($value['target'] == 'equal') {
                    $targetDPIs = $original['dpis'];
                }

                if (is_int($value['target'])) {
                    $targetDPIs = $value['target'];
                }
            }
        }


        if ($targetDPIs != 0) {
            $targetWidth = round($targetDPIs * $original['px']['width'] / $original['dpis']);
            $targetHeight = round($targetDPIs * $original['px']['height'] / $original['dpis']);
        }

    }

    // Adjust minHeight and minWidth according to the actual original
    if (isset($derivativeTypes[$derivativeType]['minWidth']) && $derivativeTypes[$derivativeType]['minWidth'] > $original['px']['width']) $derivativeTypes[$derivativeType]['minWidth'] = $original['px']['width'];
    if (isset($derivativeTypes[$derivativeType]['minHeight']) && $derivativeTypes[$derivativeType]['minHeight'] > $original['px']['height']) $derivativeTypes[$derivativeType]['minHeight'] = $original['px']['height'];

    //CHECK MAXIMUM WIDTH
    if (isset($derivativeTypes[$derivativeType]['maxWidth'])) {
        if ($targetWidth > $derivativeTypes[$derivativeType]['maxWidth']) {
            $targetDPIs = floor($derivativeTypes[$derivativeType]['maxWidth'] * $original['dpis'] / $original['px']['width']);
            //$targetWidth = round($targetDPIs * $original['px']['width'] / $original['dpis']);
            $targetHeight = round($targetDPIs * $original['px']['height'] / $original['dpis']);

            // Did this compromise the minHeight ? If so we widen the maxWidth
            echo "$original is \n";
            print_r($original);
            echo "dpisUnit is " . $original['dpisUnit'] . "\n";
            echo "depth is " . $original['depth'] . "\n";
            echo "targetWidth is " . $targetWidth . "\n";
            echo "targetHeight is " . $targetHeight . "\n";
            echo "minHeight is " . $derivativeTypes[$derivativeType]['minHeight'] . "\n";
            echo "original width is " . $original['px']['width'] . "\n";
            echo "original height is " . $original['px']['height'] . "\n";
            if (isset($derivativeTypes[$derivativeType]['minHeight'])) {
                if ($targetHeight < $derivativeTypes[$derivativeType]['minHeight']) {
                    $correction = $derivativeTypes[$derivativeType]['minHeight'] / $targetHeight;
                    $derivativeTypes[$derivativeType]['maxWidth'] = $correction * $derivativeTypes[$derivativeType]['maxWidth'];
                    echo "Correction of " . $correction . " to " . $derivativeTypes[$derivativeType]['maxWidth'] . "\n";
                    $targetDPIs = floor($derivativeTypes[$derivativeType]['maxWidth'] * $original['dpis'] / $original['px']['width']);
                    //$targetWidth = round($targetDPIs * $original['px']['width'] / $original['dpis']);
                    $targetHeight = round($targetDPIs * $original['px']['height'] / $original['dpis']);
                }
            }
        }
    }

    //CHECK MAXIMUM HEIGHT
    if (isset($derivativeTypes[$derivativeType]['maxHeight'])) {
        if ($targetHeight > $derivativeTypes[$derivativeType]['maxHeight']) {
            $targetDPIs = floor($derivativeTypes[$derivativeType]['maxHeight'] * $original['dpis'] / $original['px']['height']);
            $targetWidth = round($targetDPIs * $original['px']['width'] / $original['dpis']);
            //$targetHeight = round($targetDPIs * $original['px']['height'] / $original['dpis']);

            // Did this compromise the minWidth ? If so we widen the maxHeight
            echo "$original is \n";
            print_r($original);
            echo "dpisUnit is " . $original['dpisUnit'] . "\n";
            echo "depth is " . $original['depth'] . "\n";
            echo "targetWidth is " . $targetWidth . "\n";
            echo "targetHeight is " . $targetHeight . "\n";
            echo "minHeight is " . $derivativeTypes[$derivativeType]['minHeight'] . "\n";
            echo "original width is " . $original['px']['width'] . "\n";
            echo "original height is " . $original['px']['height'] . "\n";
            if (isset($derivativeTypes[$derivativeType]['minWidth'])) {
                if ($targetWidth < $derivativeTypes[$derivativeType]['minWidth']) {
                    $correction = $derivativeTypes[$derivativeType]['minWidth'] / $targetWidth;
                    $derivativeTypes[$derivativeType]['maxHeight'] = $correction * $derivativeTypes[$derivativeType]['maxHeight'];
                    echo "Correction of " . $correction . " to " . $derivativeTypes[$derivativeType]['maxHeight'] . "\n";
                    $targetDPIs = floor($derivativeTypes[$derivativeType]['maxHeight'] * $original['dpis'] / $original['px']['height']);
                    //$targetWidth = round($targetDPIs * $original['px']['width'] / $original['dpis']);
                    //$targetHeight = round($targetDPIs * $original['px']['height'] / $original['dpis']);
                }
            }
        }
    }


    //FORCED VALUES USED FOR GENERATING THUMBS
    if (isset($derivativeTypes[$derivativeType]['forceWidth'])) {

        $commmand = "convert -limit memory 1024 \"" . $input . "\" ";
        $commmand .= "-thumbnail " . $derivativeTypes[$derivativeType]['forceWidth'] . "x ";

        if (isset($derivativeTypes[$derivativeType]['quality'])) {
            $commmand .= "-quality " . $derivativeTypes[$derivativeType]['quality'] . " ";
        }

        $commmand .= "-density 72 -strip ";
        $commmand .= "\"" . $output . "." . $derivativeTypes[$derivativeType]['extension'] . "\" ";

    } else {

        $commmand = "convert -limit memory 1024 \"" . $input . "\" ";
        $commmand .= "-compress " . $derivativeTypes[$derivativeType]['encode'] . " ";

        if (isset($derivativeTypes[$derivativeType]['quality'])) {
            $commmand .= "-quality " . $derivativeTypes[$derivativeType]['quality'] . " ";
        }

        $commmand .= "-resample " . $targetDPIs . " ";
        $commmand .= "-density " . $targetDPIs . " ";
        $commmand .= "\"" . $output . "." . $derivativeTypes[$derivativeType]['extension'] . "\" ";

    }

    if (isset($commandOutput)) {
        unset($commandOutput);
    }

    if (isset($commandReturn_var)) {
        unset($commandReturn_var);
    }

    echo "command=" . $commmand . "\n";
    exec($commmand, $commandOutput, $commandReturn_var);

    if (!file_exists($output . "." . $derivativeTypes[$derivativeType]['extension'])) {
        echo "ERROR: OUTPUT FILE WAS NOT CREATED\n";
        echo "COMMAND OUTPUT: " . $commandOutput . "\n";
        echo "COMMAND RETURN VAR: " . $commandReturn_var . "\n";
        //exit();
    } else {
        echo "OK!\n";

        if (count($commandOutput) > 0) {
            echo "WARNING: " . $commandOutput . "\n";
        }

        if ($commandReturn_var != 0) {
            echo "WARNING: " . $commandReturn_var . "\n";
        }
    }

}


//GET COMMAND LINE OPTIONS
//i=input file; o=output file; l=derivative level; h=px height; w=px width;x=dpi x, y=dpi y, z=depth
$options = getopt("i:o:l:p:h:w:x:y:z:");


//CHECK COMMAND LINE OPTIONS

if (isset($options['i'])) {
    if (!file_exists($options['i'])) {
        exit("\nORIGINAL FILE NOT FOUND\n");
    }
} else {
    exit("\nORIGINAL FILE NOT DEFINED\n");
}

if (isset($options['l'])) {
    if (!isset($derivativeTypes[$options['l']])) {
        exit("\nUNKNOWN DERIVATIVE TYPE\n");
    }
} else {
    exit("\nDERIVATIVE TYPE NOT DEFINED\n");
}

if (isset($options['p'])) {
    $p = explode(',', $options['p']);
    foreach ($p as $option) {
        $v = explode('=', $option);
        $options[$v[0]] = $v[1];
    }
}

if (!isset($options['w'])) {
    exit("\nWIDTH NOT DEFINED\n");
}

if (!isset($options['h'])) {
    exit("\nHEIGHT NOT DEFINED\n");
}

if (!isset($options['x'])) {
    exit("\nDPI x NOT DEFINED\n");
}

if (!isset($options['y'])) {
    exit("\nDPI y NOT DEFINED\n");
}

// i = inputfile; o = outputfile; l=derivative level
generateDerivative($options['i'], $options['o'], $options['l'], $options['w'], $options['h'], $options['x'], $options['y'], $options['z']);
?>