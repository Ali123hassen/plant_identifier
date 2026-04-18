<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use App\Services\PlantNetService;

class PlantServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(PlantNetService::class, function ($app) {
            return new PlantNetService();
        });
        
        $this->app->bind(PlantNetService::class, PlantNetService::class);
    }

    public function boot(): void
    {
        //
    }
}