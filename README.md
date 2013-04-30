Magnetic flux noise in SQUIDs
====

Matlab programs to import, plot, and analyze flux noise data acquired at UC Berkeley.

Steven M. Anton<br>
Department of Physics<br>
UC Berkeley

Introduction
---------------

To handle the plotting and analysis of all of the flux noise data, I've implemented an object-oriented solution that relies on a suite of five classes and a few key important programs. The collection should allow one to work relatively seamlessly with what would otherwise be a daunting set of data.

I've tried to implement each class so that the properties and methods associated with it embody a relatively independent conceptual unit. For instance, each flux noise measurement involves a time capture and its corresponding spectrum, but a spectrum can exist outside the context of a flux noise measurement, so there's a spectrum class. I can plot a spectrum, add it to another spectrum, or scale it by some multiplicative factor quite independently of how it was acquired or how it fits into a measurement. In this way, I can implement a "spectrum" class, where its properties include the array of frequency points and their corresponding spectral densities and its methods include some plotting functions, an adding function, and an averaging function. How one goes about grouping concepts into classes is somewhat arbitrary and can come down to personal taste. I've implemented my classes according to my needs and preferences and I hope that you find them useful.

Class overview
---------------

The highest level class that I've implemented (tcMeas.m) corresponds to what I call a single measurement, that is, a single time capture and the context in which that time capture was taken. Properties of this class include things like the time of the measurement, temperature, bias currents, the flux sensitivity measurement, properties of the readout electronics, etc.. The next lowest level class (tcFFT.m) contains properties regarding the computation of the FFT. In general, I would say that the computation of an FFT hardly merits its own class, but in the way in which I compute the FFT involves a decently involved method of stitching multiple FFT's of a varying number of averages, which I felt did not belong in a spectrum class. So in this class I store stitching and averaging information as well as the influence of drift. The next lower level class is the class implementing spectra (spectrum.m), which I discussed above. This class contains information for the FFT (or the second spectrum, if you're interested in calculating that as well). The lowest level class implements time captures (timeCapture.m). The key methods of this last class involve IO of time capture files and a couple plotting routines. Finally, a class (sFit.m) exists that implements a fitting of a spectrum, allowing one to easily adjust fitting parameters, coefficients, fit errors, labels, etc.

It is also worth noting that all of these classes are implemented as handle classes. This Matlab jargon is equivalent to saying that the variable that is returned when one creates a class object is just a pointer to the object in memory. In other words, if I have a handle class myClass with a property 'val', I can create (instantiate) an object (>> A = myClass;) and set the value (>> A.val = 10). I can then make a copy (>> B = A;), but both variables point to the same object so that if I change the value of one (>> B.val = 20;), then the value of the other also changes:

    >> A.val
    ans =
        20
        
This implementation is really handy when you want to refer to the data often, but you rarely manipulate it. This way I can have multiple variables pointing to the same measurement without having multiple copies of the measurement, which I don't really need.

The tcMeas class and its properties, which include the other four classes, contain all the information one would want to know about a single measurement. But when taking data on a single device, we can have a large number of single measurements, for instance measurements acquired at different temperatures. For all the measurements taken on a single device, we create an array of tcMeas objects, `tcMall`. I could have implemented another class for this purpose, but I never really saw much advantage to doing so; an array works just fine. Once we have `tcMall`, we can start to do interesting things with the data. Typically, I use just two high level programs to generate all of the plots that I need. The first, plotSpectra.m, takes `tcMall` as an argument and plots the spectra for a specific subset specified within plotSpectra. By commenting and uncommenting the intro lines in the program, we can rapidly designate exactly which spectra we want to look at. For instance, we can look at the spectra at a single temperature, a range of temperatures, spectra taken at 0.25 Phi0, spectra with a maximum frequency of 400 Hz, spectra corresponding to a specific SQUID, etc. In this program, there is also the ability to control and plot the fits corresponding to these spectra. We can also change units or average spectra that correspond to consecutive measurements.

The second major program that I use is plotFitCoefficients.m. In this program, similar to the last,  one has the ability to select measurements fitting certain criteria and plot the fit coefficients. You can adjust the parameters of the fit routine, such as the minimum fig frequency, right from this program.

Generally, the coefficients are plotted versus temperature, but you can easily plot versus geometry or SQUID number if you choose.

Adding a new device profile
---------------

I've organized my measurements by fridge runs. Each run is given a unique run name for easy reference later on and disambiguation. Since we generally only measure a particular device one time, the run name is often just some description of the device.

To add a new measurement, you have to modify two files. The first is `spectraFilesDatabase.m`. This program contains all the directory information for each run. Open the program and look at the switch statement with a large number of cases. Each case corresponds to a run and instructs the program in which folders it should recursively look for time captures corresponding to that run and which folders it should exclude from its search. The syntax is similar between runs, so copy the last run and paste it at the end. Change the run name (case {runName}) to whatever you've called the current run and then add the folder name where the data is stored to the toAdd statement. If there's any folder you want to exclude, like "\crap_data", then add that with a `toSub` line:

    toSub{end+1} = 'crap_data';
    
The program will also automatically remove anything with the words "test" or "troubleshooting". Now, the program knows where to look for the data. (Note: this directlry is also where you should be saving your LabView data.)

The next program to change is `measurementProfile.m`. This program contains all the information regarding calibrated parameters for each run. Such parameters include the mutual inductance of the input and feedback coils, dVFLL/dPhi, the compensating resistance, and the mutual inductances of the measured SQUIDs. It also, importantly, has information about the dates over which the run occurred. The dates are important because they are how the programs know which measurement is which. That is, `tcMeas` calls `measurementProfile` with the start time and date specified in the header file as an input. Then `measurementProfile` searches through all the specified measurement profiles, finds the one that matches the measurement time, and returns the profile corresponding to that time. If you get the dates wrong, the profile won't match up with the measurement. Adding the necessary entry is pretty easy. Assuming you don't change readout SQUIDs, then you just copy the previous entry and change the `runName`, `startDate`, `stopDate`, and the mutual inductances of the measured SQUIDs.

One final optional program exists for modifying the info of time captures, `conditionTCs.m`. Suppose your time capture is just about to finish and the temperature abruptly changes and you get a spike in your data. Most of it's still good, so you don't want to throw away the whole time capture. What you can do is create an entry in `conditionTCs` that specifies a maximum time (tMax) for right before the spike occurs. This entry will instruct the programs to ignore any data that occurs after tMax. You can do something similar for tMin. The syntax should be obvious by looking at the previous runs.

Initializing `tcMall`
---------------

Before we begin looking at any data, we must first initialize the array `tcMall`. To do this, we need to decide which data we want to look at, that is, which fridge runs. We can load the data from the run called 'MIT5B3_c1', which is the first cool-down of the MIT device 5B3, with the following code:

    >> tcMall = spectraFiles('MIT5B3_c1');
    
What's happening in this line? For the specified run, the program spectraFiles looks up the directory information in spectraFilesDatabase then recursively searches the directory(ies) for time capture files (files ending in "_tc.dat"). It then removes any files where any part of the full path matches one of the `toSub` directories specified in spectraFilesDatabase. Finally, each file in the list is converted to a tcMeas object and added to the array `tcMall`.

If you acquire another time capture after you've already initialized `tcMall`, which happens all the time if you're plotting the data in Matlab while you're acquiring it, you can just run

    >> tcMall = spectraFiles(tcMall);
	
When spectraFiles encounters `tcMall` as an argument, it does the following. First, it identifies all of the unique runName's in the `tcMall`. In this example, there's only one run: MIT5B3_c1.  Next, it again recursively searches all the folders, looking for time capture files and throwing away those matching any element of `toSub`. It will then compare this new list of filenames to the filenames in `tcMall` and import only the new ones. Alternatively, you could reimport everything as when we first initialized `tcMall`, but, as we will see, this process will lose all the information stored in `tcMall`. (Note that if you change any of the information in the header file of a file already imported into `tcMall`, those changes will not be reflected unless you reimport it! Often, the easiest way to do this is to reimport the whole run.)

The program spectraFiles actually does more than intitialize and update `tcMall` corresponding to a single run. Let's say we want to look at the second MIT device, 'MIT5C3_c1'. We can add that run to the `tcMall` array by

    >> tcMall = spectraFiles(tcMall,'MIT5C3_c1');
    
As discussed previously, this line will look for new files for all the runName's existing in `tcMall`. It will also add all the files corresponding to MIT5C3_c1. In this example then, we can see that there are two runs stored in `tcMall`:

    >> unique({tcMall.runName})
    ans =
        'MIT5B3_C1'    'MIT5BC_C1'


Plotting spectra
---------------


