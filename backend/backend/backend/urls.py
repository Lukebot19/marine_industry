"""api URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
"""

from django.contrib import admin
from django.conf import settings
from django.conf.urls.static import static

from django.http import HttpResponse
from django.urls import path, include, re_path
from django.utils.translation import gettext_lazy as _


# Schema Generation
from drf_yasg import openapi
from drf_yasg.views import get_schema_view


from rest_framework.permissions import AllowAny
from rest_framework.routers import DefaultRouter


# Import routers here
# from {app}.urls import router as {app}_router
# Please remember to use api.{app}.urls for nested apps
from vessels.urls import router as vessels_router

# Base API Root
router = DefaultRouter()

app_routers = [
    vessels_router.registry,
]
for app_router in app_routers:
    router.registry.extend(app_router)

# Default API Info for Schema Generation
api_info = openapi.Info(
    title="Vessels App API",
    default_version="v1",
    description="API for managing vessels and their locations",
)
settings.SWAGGER_SETTINGS["DEFAULT_INFO"] = api_info

# Schema
schema_view = get_schema_view(
    public=True,
    permission_classes=[AllowAny],
)

admin.site.site_title = _("Vessels Admin")
admin.site.site_header = _("Vessels Administration")
admin.site.index_title = _("Control Center Home")

urlpatterns = [
    path("api/admin/", admin.site.urls),
    # DRF API Viewer Login/Logout
    path("api/auth/", include("rest_framework.urls")),
    # Versioned endpoints from the router registry
    path("api/v1/", include(router.urls)),
    # Schema and OpenAPI
    re_path(
        r"^api/swagger(?P<format>\.json|\.yaml)$",
        schema_view.without_ui(cache_timeout=0),
        name="schema-json",
    ),
    re_path(
        r"^api/docs/$",
        schema_view.with_ui("redoc", cache_timeout=0),
        name="schema-redoc",
    ),
    # Navigation Block for those who go to /api/
    path(
        "api/",
        lambda _: HttpResponse(
            '<body style="background-color: #8E8E8E">'
            '<div style="padding: 20px; border: 5px solid black;'
            "background-color: #B2BB1C; max-width: 415px; color: white;"
            "font-family: Helvetica, Sans-Serif; font-size: 1.2em;"
            'margin: 20vh auto;">'
            "<p>Please navigate to:</p>"
            "<p>> <a href='/api/admin/'>/api/admin/</a> for Vessel API Admin</p>"
            "<p>> <a href='/api/v1/'>/api/v1/</a> for current endpoints</p>"
            "<p>> <a href='/api/docs/'>/api/docs/</a> for an API Spec</p>"
            "<p>> <a href='/api/swagger.json'>/api/swagger.json</a> to download API Spec</p>"
            "</div></body>",
            headers={"content-type": "text/html"},
            status=200,
        ),
        name="api-test",
    ),

    path(
        "",
        lambda _: HttpResponse(
            '<div style="max-width: 400px;font-family: Helvetica, Sans-Serif;'
            'font-size: 1.2em;margin: 20vh auto;">'
            '<p>"<strong>200 OK.</strong> Welcome to the Vessel API."</p>'
            "</div>",
            headers={"content-type": "text/html"},
            status=200,
        ),
        name="api-test",
    ),
]
