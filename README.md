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

## Recording
