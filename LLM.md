# LLM - Application Overview

## Application Description
This document provides a detailed overview of the application's functionality, including its features, endpoints, and purpose.

### General Description
The application is a property rental platform that allows users to explore, manage, and rent properties. It integrates with various services such as Firebase for authentication, storage, and database management, as well as Google Maps for location-based features.

## Features

### User Authentication
- **Sign Up**: Users can create an account using email and password.
- **Login**: Users can log in to their account.
- **Password Recovery**: Users can reset their password if forgotten.

### Property Management
- **Explore Properties**: Users can browse available properties with images and details.
- **Add Property**: Property owners can list their properties for rent.
- **Edit Property**: Owners can update property details.
- **Delete Property**: Owners can remove their properties from the listing.

### Location Services
- **Map Integration**: Users can view property locations on a map using Google Maps.
- **Search by Location**: Users can search for properties in specific areas.

### Media Management
- **Image Upload**: Users can upload images of properties.
- **Image Display**: Property images are displayed in the app.

### Notifications
- **Push Notifications**: Users receive updates about their properties and rental status.

### Payment Integration
- **Rent Payments**: Tenants can pay rent through the app.
- **Payment History**: Users can view their payment history.

## Endpoints

### Base URL
The base URL for all API endpoints is configured in the application settings. It is typically defined in the `lib/services` directory or environment configuration files.

### Authentication Endpoints
- **POST /auth/signup**: Registers a new user.
- **POST /auth/login**: Authenticates a user.
- **POST /auth/password-reset**: Sends a password reset email.

### Property Endpoints
- **GET /properties**: Retrieves a list of all properties.
- **POST /properties**: Adds a new property.
- **PUT /properties/{id}**: Updates a property by ID.
- **DELETE /properties/{id}**: Deletes a property by ID.

### Location Endpoints
- **GET /locations**: Retrieves location data for properties.
- **POST /locations/search**: Searches for properties in a specific location.

### Media Endpoints
- **POST /media/upload**: Uploads property images.
- **GET /media/{id}**: Retrieves a property image by ID.

### Payment Endpoints
- **POST /payments**: Processes a rent payment.
- **GET /payments/history**: Retrieves payment history for a user.

## Technologies Used
- **Frontend**: Flutter framework for cross-platform development.
- **Backend**: Firebase services for authentication, database, and storage.
- **Maps**: Google Maps API for location-based features.
- **Payments**: Integration with a payment gateway for rent transactions.

## Additional Notes
- The application follows best practices for security and performance.
- ProGuard rules are configured to optimize and secure the APK.
- The app supports multiple platforms, including Android, iOS, web, and desktop.