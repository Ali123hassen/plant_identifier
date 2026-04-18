<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Plant extends Model
{
    use HasFactory;

    protected $fillable = [
        'scientific_name',
        'common_name',
        'family',
        'image_url',
        'needs_water',
        'needs_fertilizer',
        'needs_sunlight',
        'care_instructions',
        'description',
    ];

    protected $casts = [
        'needs_water' => 'boolean',
        'needs_fertilizer' => 'boolean',
        'needs_sunlight' => 'boolean',
    ];
}