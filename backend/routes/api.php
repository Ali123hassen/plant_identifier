<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\PlantController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {
    // التعرف على النبات
    Route::post('/identify', [PlantController::class, 'identify']);
    Route::post('/identify/base64', [PlantController::class, 'identifyBase64']);
    
    // معلومات النبات
    Route::get('/plants/{id}', [PlantController::class, 'show']);
    Route::post('/plants', [PlantController::class, 'store']);
    
    // فحص حالة API
    Route::get('/health', function () {
        return response()->json([
            'success' => true,
            'message' => 'Plant API is running',
            'version' => '1.0.0',
        ]);
    });
});