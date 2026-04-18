<?php

namespace App\Http\Controllers;

use App\Services\PlantNetService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;
use Illuminate\Routing\Controller;

class PlantController extends Controller
{
    protected PlantNetService $plantNetService;

    public function __construct(PlantNetService $plantNetService)
    {
        $this->plantNetService = $plantNetService;
    }

    /**
     *认识 نبات من صورة
     */
    public function identify(Request $request): JsonResponse
    {
        try {
            if (!$request->hasFile('image')) {
                return response()->json([
                    'success' => false,
                    'message' => 'لم يتم إرسال صورة',
                ], 400);
            }

            $image = $request->file('image');
            
            // Save to temp file
            $tempPath = tempnam(sys_get_temp_dir(), 'plant_') . '.jpg';
            file_put_contents($tempPath, $image->getContent());

            $result = $this->plantNetService->identifyPlant($tempPath);
            
            // Clean up temp file
            @unlink($tempPath);

            return response()->json($result);
        } catch (\Exception $e) {
            Log::error('Plant Identification Error', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ في التعرف على النبات',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * التعرف على نبات من صورة Base64
     */
    public function identifyBase64(Request $request): JsonResponse
    {
        $request->validate([
            'image' => 'required|string',
        ]);

        try {
            $base64Image = $request->input('image');
            $base64Image = preg_replace('/^data:image\/\w+;base64,/', '', $base64Image);

            $result = $this->plantNetService->identifyPlantFromBase64($base64Image);

            return response()->json($result);
        } catch (\Exception $e) {
            Log::error('Plant Identification Base64 Error', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'حدث خطأ في التعرف على النبات',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * الحصول على معلومات نبات معين
     */
    public function show(int $id): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => 'معلومات النبات',
            'data' => [
                'id' => $id,
                'name' => 'نبات تجريبي',
                'care' => [
                    'water' => 'كل 3 أيام',
                    'fertilizer' => 'شهرياً',
                    'sunlight' => 'ضوء ساطع غير مباشر',
                ],
            ],
        ]);
    }

    /**
     * حفظ نتيجة النبات
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'scientific_name' => 'required|string',
            'common_name' => 'required|string',
            'confidence' => 'required|numeric',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'تم حفظ نتيجة النبات بنجاح',
            'data' => $request->all(),
        ]);
    }
}