<?php

use Illuminate\Foundation\Artisan;

Artisan::command('inspire', function () {
    $this->comment(Artisan::call('inspire'));
})->purpose('Display an inspiring quote');