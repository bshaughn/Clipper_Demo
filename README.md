CLIPPER DEMO

This is a simulator for a nautical-themed barbershop called Clipper which operates out of a converted houseboat docked at the local pier. The shop has 4 barber chairs and a waiting area for 4 additional customers. The working day is dividied into 2 4-hour shifts with 4 barbers on each shift.  

It's implemented for iPhone using xibs and GCD. You can run the program by cloning this repo and clicking the "play" button in Xcode. Program has been tested and verified on Xcode 16. UI has been tested on iPhone 11 (simulator) and later models.

The simulator has an adjustable timescale which the user can change using the slider. At the bottom position the simulation pauses. Toward the top of the slider there are 2 different fast-forward speeds. At max speed one full working day at the shop will take about 6 seconds. The timescale is divided into minutes ranging from 0(midnight) to 1339(11:59pm). The shop is open from 9am to 5pm with second shift barbers sometimes staying late to finish their last ustomer's haircut. 

During the working day customers arrive every 5 minutes. After the shop closes there can be some confused people who want night-time haircuts but only receive disappointment. 

Additionally there is a feature which allows customer arrival events to be pre-loaded from a text file. Each line of the file has 3 comma-separated values: customer name, arrival time (between 0 and 1339)  and haircut duration as in this example:
Customer-44, 775, 27
Customer-45, 772, 29
Customer-45, 776, 24
Customer-46, 777, 39
Customer-47, 778, 35

I had a lot of fun putting this together and I hope you enjoy it! :)
