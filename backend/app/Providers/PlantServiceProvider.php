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
    }

    public function boot(): void
    {
        //
    }
}