from django.urls import path, include
from rest_framework.routers import SimpleRouter

from . import viewsets

router = SimpleRouter()
router.register(r"vessels", viewsets.VesselViewSet, basename="vessels")

# URL Patterns is kept for backwards compatibility with certain Django functionality.
urlpatterns = [
    path("", include(router.urls)),
]
