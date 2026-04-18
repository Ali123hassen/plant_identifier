<?php

use Illuminate\Support\Facades\Route;

// Web routes (session, CSRF, etc. middleware applied)
Route::middleware('web')->group(function () {
    // Add web routes here if needed
});