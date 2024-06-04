from django.db import models
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from django.core.serializers import serialize


class Vessel(models.Model):
    name = models.CharField(max_length=100)
    longitude = models.FloatField()
    latitude = models.FloatField()

    def __str__(self):
        return self.name


@receiver(post_save, sender=Vessel)
def vessel_saved(sender, instance, created, **kwargs):
    vessel_data = serialize("json", [instance])
    message = {
        "type": "vessel.update",
        "text": vessel_data,
    }
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)("vessels", message)


@receiver(post_delete, sender=Vessel)
def vessel_deleted(sender, instance, **kwargs):
    message = {
        "type": "vessel.delete",
        "text": {"id": instance.id},
    }
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)("vessels", message)
