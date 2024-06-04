# consumers.py
from channels.generic.websocket import AsyncWebsocketConsumer
import json


class VesselConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # Join the "vessels" group
        await self.channel_layer.group_add("vessels", self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        # Leave the "vessels" group
        await self.channel_layer.group_discard("vessels", self.channel_name)

    async def receive(self, text_data):
        pass

    async def vessel_update(self, event):
        await self.send(
            text_data=json.dumps(
                {
                    "type": event["type"],
                    "data": event["text"],
                }
            )
        )

    async def vessel_delete(self, event):
        await self.send(
            text_data=json.dumps(
                {
                    "type": event["type"],
                    "data": event["text"],
                }
            )
        )
