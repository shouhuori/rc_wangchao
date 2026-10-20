<?php

use App\Http\Controllers\EventIntakeController;
use App\Http\Middleware\ApiToken;
use Illuminate\Support\Facades\Route;

Route::post('/events', EventIntakeController::class)->middleware(ApiToken::class);
