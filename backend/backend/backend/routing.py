from django.urls import path

from . import consumer

websocket_urlpatterns = [
    path("ws/vessels/", consumer.VesselConsumer.as_asgi()),
]
