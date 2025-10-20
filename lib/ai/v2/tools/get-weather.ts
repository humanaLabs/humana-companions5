import { tool } from "ai";
import { z } from "zod";

async function geocodeCity(
  city: string
): Promise<{ latitude: number; longitude: number } | null> {
  try {
    const response = await fetch(
      `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(city)}&count=1&language=en&format=json`
    );

    if (!response.ok) {
      return null;
    }

    const data = await response.json();

    if (!data.results || data.results.length === 0) {
      return null;
    }

    const result = data.results[0];
    return {
      latitude: result.latitude,
      longitude: result.longitude,
    };
  } catch {
    return null;
  }
}

export const getWeather = tool({
  description:
    "Get the current weather at a location. You can provide either coordinates or a city name.",
  inputSchema: z.object({
    latitude: z.number().optional(),
    longitude: z.number().optional(),
    city: z
      .string()
      .describe("City name (e.g., 'San Francisco', 'New York', 'London')"),
  }),
  execute: async (input) => {
    console.log(
      "[getWeather Tool] 🌤️  EXECUTING with input:",
      JSON.stringify(input)
    );

    let latitude: number;
    let longitude: number;

    try {
      if (input.city) {
        console.log("[getWeather Tool] 📍 Geocoding city:", input.city);
        const coords = await geocodeCity(input.city);
        if (!coords) {
          console.log(
            "[getWeather Tool] ❌ Failed to geocode city:",
            input.city
          );
          return {
            error: `Could not find coordinates for "${input.city}". Please check the city name.`,
          };
        }
        console.log("[getWeather Tool] ✅ Coordinates found:", coords);
        latitude = coords.latitude;
        longitude = coords.longitude;
      } else if (
        input.latitude !== undefined &&
        input.longitude !== undefined
      ) {
        latitude = input.latitude;
        longitude = input.longitude;
        console.log("[getWeather Tool] 📍 Using provided coordinates:", {
          latitude,
          longitude,
        });
      } else {
        console.log(
          "[getWeather Tool] ❌ Invalid input: missing city or coordinates"
        );
        return {
          error:
            "Please provide either a city name or both latitude and longitude coordinates.",
        };
      }

      console.log("[getWeather Tool] 🌐 Fetching weather data...");
      const response = await fetch(
        `https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m&hourly=temperature_2m&daily=sunrise,sunset&timezone=auto`
      );

      if (!response.ok) {
        console.log("[getWeather Tool] ❌ Weather API error:", response.status);
        throw new Error(`Weather API returned ${response.status}`);
      }

      const weatherData = await response.json();
      console.log("[getWeather Tool] ✅ Weather data received");

      if (input.city) {
        weatherData.cityName = input.city;
      }

      console.log("[getWeather Tool] 🎉 Execution successful!");
      return weatherData;
    } catch (error) {
      console.error("[getWeather Tool] ❌ ERROR during execution:", error);
      throw error;
    }
  },
});
