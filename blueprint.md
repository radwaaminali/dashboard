
# Blueprint: Luna Store Admin Dashboard

## Overview

This document outlines the plan for creating the "Luna Store Admin" dashboard application using Flutter in Firebase Studio. The goal is to build a responsive, visually appealing, and functional admin panel for an e-commerce store, with backend services provided by Supabase.

## Design & Style

*   **Layout:** A responsive design with a fixed sidebar for large screens and a collapsible drawer for mobile. The main area is split into a top bar and a content section.
*   **Color Palette (Dark Theme):**
    *   **Backgrounds:** Dark Slate Gray (`#2C3E50`), Deep Cove (`#34495E`).
    *   **Accent/Primary:** Turquoise (`#1ABC9C`).
    *   **Text:** White (`#FFFFFF`), Light Gray (`#BDC3C7`).
    *   **Status Colors:** Green (`#2ECC71` for Success), Orange (`#E67E22` for Pending), Red (`#E74C3C` for Failed).
*   **Typography:** Using `google_fonts` for a modern look. `Oswald` for titles and `Roboto` for body text.

## Implemented Features

*   **Dashboard Screen:** A responsive screen showing stats, charts, and a filterable orders list.
*   **Responsive UI Components:** Stats cards and orders table adapt to different screen sizes.
*   **Basic Theming:** A dark theme with a consistent color scheme.
*   **Login Page:** A responsive login screen with email/password fields and validation.

## Current Plan

**Step 1: Integrate Supabase**
*   Add `supabase_flutter` dependency.
*   Initialize Supabase client in `main.dart` with the provided URL and anon key.

**Step 2: Implement Supabase Authentication**
*   Update `login_page.dart` to use `supabase.auth.signInWithPassword`.
*   Provide user feedback for successful login or errors.
