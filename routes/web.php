<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ConfigurationController;
use App\Http\Controllers\ConsoleController;
use App\Http\Controllers\OperationsController;
use App\Http\Controllers\SourceController;
use Illuminate\Support\Facades\Route;

Route::get('/login', [AuthController::class, 'form'])->name('login')->middleware('guest');
Route::post('/login', [AuthController::class, 'login'])->middleware('guest');
Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth');
Route::middleware('auth')->group(function () {
    Route::get('/sources', [SourceController::class, 'index']);
    Route::get('/sources/create', [SourceController::class, 'form']);
    Route::get('/sources/{id}/edit', [SourceController::class, 'form']);
    Route::post('/sources', [SourceController::class, 'create']);
    Route::post('/sources/{id}', [SourceController::class, 'update']);
    Route::post('/sources/{id}/rotate', [SourceController::class, 'rotate']);
    Route::get('/', [ConsoleController::class, 'dashboard']);
    Route::get('/events', [ConsoleController::class, 'events']);
    Route::get('/events/{id}', [ConsoleController::class, 'event']);
    Route::get('/tasks', [ConsoleController::class, 'tasks']);
    Route::get('/requests', [ConsoleController::class, 'requests']);
    Route::get('/requests/{id}', [ConsoleController::class, 'step']);
    Route::get('/dead-letters', [ConsoleController::class, 'dead']);
    Route::get('/audit', [ConsoleController::class, 'audit']);
    foreach (['providers' => 'Provider', 'endpoints' => 'Endpoint', 'workflows' => 'Workflow'] as $path => $entity) {
        Route::get('/'.$path, [ConfigurationController::class, $path]);
        Route::get('/'.$path.'/create', [ConfigurationController::class, lcfirst($entity).'Form']);
        Route::get('/'.$path.'/{id}/edit', [ConfigurationController::class, lcfirst($entity).'Form']);
        Route::post('/'.$path, [ConfigurationController::class, 'save'.$entity]);
        Route::post('/'.$path.'/{id}', [ConfigurationController::class, 'save'.$entity]);
    }
    Route::post('/workflow-validation', [ConfigurationController::class, 'validateDraft']);
    Route::post('/workflows/{id}/publish', [ConfigurationController::class, 'publish']);
    Route::post('/workflows/{id}/rollback', [ConfigurationController::class, 'rollback']);
    Route::post('/requests/{id}/retry', [OperationsController::class, 'retry']);
    Route::post('/requests/{id}/confirm', [OperationsController::class, 'confirm']);
    Route::post('/events/{id}/reconvert', [OperationsController::class, 'reconvert']);
    Route::post('/tasks/{id}/pause', [OperationsController::class, 'pause']);
    Route::post('/providers/{id}/reset-circuit', [OperationsController::class, 'resetCircuit']);
});
