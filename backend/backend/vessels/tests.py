from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from vessels.models import Vessel


class VesselModelTestCase(APITestCase):
    def setUp(self):
        # Setup client
        self.client = APIClient()
        self.url = "/api/v1/vessels/"


        self.vessel_data = {
            "name": "Test Vessel",
            "longitude": 123.45,
            "latitude": 67.89,
        }
        self.response = self.client.post(
            self.url, self.vessel_data, format="json"
        )

    def test_create_vessel(self):
        self.assertEqual(self.response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Vessel.objects.count(), 1)
        self.assertEqual(Vessel.objects.get().name, "Test Vessel")

    def test_update_vessel(self):
        vessel = Vessel.objects.get()
        new_data = {
            "name": "Updated Vessel",
            "longitude": 98.76,
            "latitude": 54.32,
        }
        response = self.client.put(
            f'{self.url}' + f'{vessel.id}/',
            new_data,
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(Vessel.objects.get().name, "Updated Vessel")

    def test_delete_vessel(self):
        vessel = Vessel.objects.get()
        response = self.client.delete(
            f'{self.url}' + f'{vessel.id}/',
            format="json",
            follow=True,
        )
        self.assertEquals(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertEqual(Vessel.objects.count(), 0)
