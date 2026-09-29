<h4>What is this ?</h4>

It's a part of 'rdc_npc' (which is private for my project), make it possible to 'sync' train&trolley(whatever you call it)
I split it up from the script so this is the WAY not the full solution.

<h4>What you should know?</h4>
after doing a little research on FiveM/RedM, you should know:
'MissionTrain' is something only sync in a proximity area, and is controlled by client not server. (which means someone get out from it then it becomes unvalid.)

<h4>What the script does?</h4>
So this script is not really to 'sync' it globally , just make sure every client to check the state from server side (every train init event send table to server includes entity Network IDs)
when the data on server side is invalid, just trigger initMissionTrain event to spawn trolleys and send the data to server side again, that's the principle of the script.
Setting a entity as a mission entity to make sure it cant be recycled by game engine automatically. and the trolley route is scripted by client itself.

<h4>*as soon as client register a local entity as mission entity, then it will keep exist and valid till disconnect or delete it manually.*</h4>
