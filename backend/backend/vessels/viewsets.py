from rest_framework import viewsets, status

from vessels.models import Vessel
from vessels.serializers import VesselSerializer

class VesselViewSet(viewsets.ModelViewSet):
    queryset = Vessel.objects.all()
    serializer_class = VesselSerializer
