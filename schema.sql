-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.users (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  full_name character varying NOT NULL,
  phone character varying NOT NULL,
  email character varying NOT NULL UNIQUE,
  user_type USER-DEFINED NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (id)
);
CREATE TABLE public.drivers (
  user_id uuid NOT NULL,
  license_number character varying NOT NULL,
  license_expiry date NOT NULL,
  insurance_document character varying NOT NULL,
  insurance_expiry date NOT NULL,
  CONSTRAINT drivers_pkey PRIMARY KEY (user_id),
  CONSTRAINT drivers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.vehicles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  driver_id uuid NOT NULL,
  brand character varying NOT NULL,
  model character varying NOT NULL,
  year integer NOT NULL CHECK (year >= 1980 AND year <= (EXTRACT(year FROM now())::integer + 1)),
  plate_number character varying NOT NULL UNIQUE,
  vehicle_type USER-DEFINED NOT NULL,
  CONSTRAINT vehicles_pkey PRIMARY KEY (id),
  CONSTRAINT vehicles_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(user_id)
);
CREATE TABLE public.passenger_addresses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  passenger_id uuid NOT NULL,
  label character varying NOT NULL,
  address text NOT NULL,
  CONSTRAINT passenger_addresses_pkey PRIMARY KEY (id),
  CONSTRAINT passenger_addresses_passenger_id_fkey FOREIGN KEY (passenger_id) REFERENCES public.users(id)
);
CREATE TABLE public.trips (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  passenger_id uuid NOT NULL,
  driver_id uuid,
  pickup_location text NOT NULL,
  dropoff_location text NOT NULL,
  payment_method USER-DEFINED NOT NULL,
  preferred_vehicle_type USER-DEFINED NOT NULL,
  route text,
  distance_km numeric,
  total_price numeric,
  status USER-DEFINED NOT NULL DEFAULT 'solicitado'::trip_status,
  requested_at timestamp with time zone NOT NULL DEFAULT now(),
  start_time timestamp with time zone,
  end_time timestamp with time zone,
  CONSTRAINT trips_pkey PRIMARY KEY (id),
  CONSTRAINT trips_passenger_id_fkey FOREIGN KEY (passenger_id) REFERENCES public.users(id),
  CONSTRAINT trips_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(user_id)
);
CREATE TABLE public.ratings (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trip_id uuid NOT NULL,
  rater_id uuid NOT NULL,
  rated_id uuid NOT NULL,
  stars smallint NOT NULL CHECK (stars >= 1 AND stars <= 5),
  review text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT ratings_pkey PRIMARY KEY (id),
  CONSTRAINT ratings_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trips(id),
  CONSTRAINT ratings_rater_id_fkey FOREIGN KEY (rater_id) REFERENCES public.users(id),
  CONSTRAINT ratings_rated_id_fkey FOREIGN KEY (rated_id) REFERENCES public.users(id)
);
CREATE TABLE public.reports (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  trip_id uuid,
  reporter_id uuid NOT NULL,
  reported_id uuid NOT NULL,
  description text NOT NULL,
  incident_datetime timestamp with time zone NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT reports_pkey PRIMARY KEY (id),
  CONSTRAINT reports_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.trips(id),
  CONSTRAINT reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.users(id),
  CONSTRAINT reports_reported_id_fkey FOREIGN KEY (reported_id) REFERENCES public.users(id)
);
