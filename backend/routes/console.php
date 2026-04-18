<?php

use Illuminate\Foundation\Artisan;
use Illuminate\Support\Facades\Artisan;

Artisan::command('inspire', function () {
    $this->comment(Artisan::call('inspire'));
})->purpose('Display an inspiring quote')->hourly();