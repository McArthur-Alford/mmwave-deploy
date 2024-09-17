# Quickstart Guide
## Starting the server
The server is in the briefcase. Powering it on, it should boot in 1-2 minutes.
Once the server is booted, some steps need to be taken to get everything communicating. To do this, open the `konsole` app, it should be searchable in the start menu. You will need to enter multiple commands, this is best done by using the "new tab" button in the top of konsole.
![image](https://github.com/user-attachments/assets/84369c59-5903-4bd4-b083-4bb1771a087c)

Once konsole is up and running, run the following commands each in a new tab:
1. Setting up automatic LAN discovery. Run `mmwave-discovery -t`
3. Starting up the NATS server for communication. Run `nats_server` 
4. Connecting the server to NATS. Run `mmwave-machine -m 10 -t`
   - This causes the server to act as a machine like the individual radars.
   - The machine should connect to NATS, and is useful for tasks like recording. If there are any errors on the server, they will appear in the logs produced by this command.
   - Additionally, once recording begins, the status should be visible in the output of this command.
5. Running the dashboard. Run `mmwave-dashboard -t`

## Starting the radars
Once the server is started, the radars can be activated by powering them on. They will automatically boot and connect. If the radars were already running, they might connect to the server properly, but they also might not. In the event that they do not connect, simply power them off and on, and give them about 2 minutes to reboot/connect.

## Using the dashboard
As described in [starting the server](#starting-the-server), the dashboard can be started with the command `mmwave-dashboard -t`.
Within the dashboard, configuration can be done on the right, and live data visualized on the left. 

### Visualisation
The pointcloud on the left can be moved with mouse drag, and zoomed with scrollwheel. There are transformation options on the top left of the visualisation, rotation and position. These allow (for visualisation purposes, they do not effect recording) transformation of the pointclouds.

### Configuration
#### Operations:

![image](https://github.com/user-attachments/assets/c6adf9e8-55f8-4abe-8a6a-ad3ed59e0e1f)
The config panel on the right should initially be empty. The top row contains four buttons, labelled 1 to 4. These are operations for applying, saving, loading and refreshing the active config. The second row contains operations for adding new devices to the config. The buttons, 1-5 are described below:

1. A greyed out button should read `config up to date`. This will become clickable if the dashboard becomes out of sync with the config used by the server, and will reset the dashboard to whatever the server is using. It shouldn't ever be relevant if only one dashboard is being used, unless the dashboard is closed and opened.
2. `load output_config.json` should load the config file from config_out.json. This will not *apply* the config to the server, only load it into the dashboard. Ignore that the button says output_config.json, that is a typo.
3. A second greyed out button should read `apply config`. Changes made to the configuration will not immediately be applied to the server. This includes changes to transformation: Changes to transform will be rendered in the visualisation, but not actually applied on the server until the apply button is clicked. If this button is clickable then you have unapplied changes to your config that will not be used until it is clicked.
4. `save config_out.json` will save the current config to config_out.json.
> [!WARNING]
> Saving will overwrite the config! If you want to back it up, open up the file browser and make a copy of config_out.json in your home directory. Name it whatever you want, the server will only use the file named config_out.json.
5. The second row features buttons for adding new "devices" to the configuration. A device could be a recorder, a zed camera, or an awr radar.

#### Devices
![image](https://github.com/user-attachments/assets/dfd98781-73a1-46d6-b10c-e39a5487f284)

The empty device shown above is purely for testing purposes, with no functionality. It shouldn't be used in production. That said, it highlights some important details of the configuration panel.

Every device has a id. As seen in the image, the id of the device is `m: 0, d: 0`. the `m` refers to the machine and `d` the device. The machine number is the number printed on each of the radars. It is also the number 10 for the server (as that is what was set when we ran the command `mmwave-machine -m 10 -t` at the start of this guide). The device number should be unique for each device on one machine, though can otherwise be arbitrary. As an example, if machine 5 had two radars, the first radar device would have id 5-1 and the second would have id 5-2.

There is also a delete button here, to remove the device.

Lastly is the color. The color is not saved, and will be lost with a dashboard reset. The color will effect the color of points produced by the device in the visualiser.

#### Radar Device
![image](https://github.com/user-attachments/assets/e9efbc20-9e45-4c6b-9e85-6997353fdb3b)

The AWR device, when added, has the above default config. The serial number is the serial number of each radar. There is no handy way to get these numbers unfortunately, though they are provided in the existing default config, which can be loaded when starting the dashboard. Below are the numbers currently being used for each machine, in case you loose them:
- M1: 00E23ED5
- M2: 00E23EA9
- M3: 00E23FD7

All radars currently use the AWR1843AOP model, not the boost. It is important this is set correctly.

The position and orientation set the x/y/z and yaw/pitch of the radar. Translation is applied *before* rotation. These units are in meters for position and degrees for orientation. There is no universal origin, or agreed upon "forward" orientation.

### Recording Device
![image](https://github.com/user-attachments/assets/ca30dec8-3560-4516-b81b-e27446050c0c)

The recording device is quite straightforward. Assign it to the machine that should be recording. If the above steps were followed, that is machine 10.
The filepath can point to a location on the device where the recording should be saved. Once the config is applied, the machine should start recording all point information to that file. Some important notes:
- The data cannot accidentally be deleted easily, however shutting the server down without first deleting the recording device in the config (and applying that change) will lead to the file missing some curly braces at the end, making it difficult to parse later. Make sure to delete the recording device prior to closing the server down.
- It is recommended to change the recording filename occasionally. Simply modifying the file path and applying will cause the machine to finish the existing file (appending the correct braces to the end of the file) and begin recording to the new file. This is simply useful to avoid storing everything in one file, which decreases the risks of data loss.
- Do NOT edit, move or rename the recording output files while they are being recorded. This will cause errors. Also note the files get quite large, and opening them in a text editor can be laggy.
