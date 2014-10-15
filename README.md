# NeuroCloud API

## BASIC Authentication

User: neuroAPI
Pass: qhsq9WqzUee7Ei

## Demo

<http://153.121.75.16/youtube> (Emotion Estimation API DEMO)

Access the URL above to record an time change of Emotion Scale on playing any YouTube video (specified by YouTube VideoId in text field below the video). Click the name of device which is connected with MindWave Mobile before playing.

## Socket.io Conenction Information

- Host: 153.121.75.16
- Port: 80
- Endpoint:
    + /view  (Use this endpoint if you are normal user)
    + [blank]  (reserved for the device connected with MindWave Mobile)

To get information about socket.io see: <http://socket.io/> (the version of socket.io is 0.9, not 1.0)

## Socket.io Events

While you are subscribing neuroAPI socket.io stream, you will get these events.

- device_list
- result
- debug (ignore!)

### device_list

You will get `device_list` event every 2-5 seconds. Its data is array of user data. 

For example:

    [{"user_display_id": "Device01", "socket_io_id": "string" }]

You have to select one device to analyze the EEG signal from the device and get Emotion Estimation Scale Data. You can select device by sending `listen` event (data is like: {"user_display_id": "Device01"})

You will be no longer listening to the old device if you sent `listen` to another device.

### result

You will get `result` event about every seconds ONLY when you are listening to other device. Data will be the array which includes 5 integers (Like, Interest, Concentration, Drowsiness, Stress).

For example: 

    {"result": [92, 72, 61, 5, 11]}
