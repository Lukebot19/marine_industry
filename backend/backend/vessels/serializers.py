from rest_framework import serializers
from vessels.models import Vessel


class VesselSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vessel
        fields = [
            "id",
            "name",
            "longitude",
            "latitude",
        ]
        read_only_fields = [
            "id",
        ]
