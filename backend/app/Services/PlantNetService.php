<?php

namespace App\Services;

use GuzzleHttp\Client;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;

class PlantNetService
{
    private string $apiKey;
    private string $baseUrl = 'https://my-api.plantnet.org';

    public function __construct()
    {
        $this->apiKey = config('services.plantnet.api_key', env('PLANTNET_API_KEY', ''));
    }

    /**
     * التعرف على النبات من الصورة
     */
    public function identifyPlant($imagePath): array
    {
        try {
            $client = new Client(['timeout' => 60]);
            
            $response = $client->post($this->baseUrl, [
                'multipart' => [
                    [
                        'name' => 'images',
                        'contents' => fopen($imagePath, 'r'),
                        'filename' => 'image.jpg',
                    ],
                ],
                'query' => [
                    'api-key' => $this->apiKey,
                    'lang' => 'ar',
                ],
            ]);

            if ($response->getStatusCode() === 200) {
                $data = json_decode($response->getBody()->getContents(), true);
                return $this->parsePlantResponse($data);
            }

            Log::error('PlantNet API Error', ['response' => $response->getBody()]);
            return $this->getFallbackIdentification($imagePath);
        } catch (\Exception $e) {
            Log::error('PlantNet Service Error', ['error' => $e->getMessage()]);
            return $this->getFallbackIdentification($imagePath);
        }
    }

    /**
     * التعرف على النبات من صورة Base64
     */
    public function identifyPlantFromBase64(string $base64Image): array
    {
        try {
            $imageData = base64_decode($base64Image);
            $tempFile = tempnam(sys_get_temp_dir(), 'plant_');
            file_put_contents($tempFile, $imageData);

            $result = $this->identifyPlant($tempFile);
            unlink($tempFile);

            return $result;
        } catch (\Exception $e) {
            Log::error('PlantNet Base64 Error', ['error' => $e->getMessage()]);
            return $this->getFallbackIdentification(null);
        }
    }

    /**
     * تحليل الاستجابة من PlantNet
     */
    private function parsePlantResponse(array $data): array
    {
        if (empty($data['results'])) {
            return $this->getFallbackIdentification(null);
        }

        $result = $data['results'][0];
        $species = $result['species'] ?? [];

        return [
            'success' => true,
            'scientific_name' => $species['scientificName'] ?? 'غير معروف',
            'common_name' => $this->getCommonName($species),
            'family' => $species['family'] ?? 'غير معروفة',
            'genus' => $species['genus'] ?? 'غير معروف',
            'confidence' => $result['score'] ?? 0,
            'needs_water' => $this->determineWaterNeed($species),
            'needs_fertilizer' => $this->determineFertilizerNeed($species),
            'needs_sunlight' => $this->determineSunlightNeed($species),
            'care_instructions' => $this->getCareInstructions($species),
            'description' => $this->getDescription($species),
        ];
    }

    /**
     * الحصول على الاسم الشائع
     */
    private function getCommonName(array $species): string
    {
        $commonNames = $species['commonNames'] ?? [];
        if (!empty($commonNames)) {
            return is_array($commonNames) ? reset($commonNames) : $commonNames;
        }
        return 'نبات غير معروف';
    }

    /**
     * تحديد الحاجة للماء
     */
    private function determineWaterNeed(array $species): bool
    {
        // منطق بسيطة - معظم النباتات تحتاج ماء
        return true;
    }

    /**
     * تحديد الحاجة للسماد
     */
    private function determineFertilizerNeed(array $species): bool
    {
        // السماد seasonally
        return true;
    }

    /**
     * تحديد الحاجة للضوء
     */
    private function determineSunlightNeed(array $species): bool
    {
        // Most plants need sunlight
        return true;
    }

    /**
     * الحصول على تعليمات العناية
     */
    private function getCareInstructions(array $species): string
    {
        return "• ري النبات بانتظام\n" .
               "•'exposition للضوء الساطع\n" .
               "• تسميد شهرياً في موسم النمو\n" .
               "• فحص الأوراق بانتظام";
    }

    /**
     * الحصول على الوصف
     */
    private function getDescription(array $species): string
    {
        $name = $this->getCommonName($species);
        return "نبات {$name} من فصيلة {$species['family'] ?? 'غير معروفة'}";
    }

    /**
     * نتيجة افتراضية في حالة فشل API
     */
    private function getFallbackIdentification($imagePath): array
    {
        return [
            'success' => false,
            'scientific_name' => 'غير معروف',
            'common_name' => 'تعذر التعرف على النبات',
            'family' => 'غير معروفة',
            'confidence' => 0,
            'needs_water' => true,
            'needs_fertilizer' => true,
            'needs_sunlight' => true,
            'care_instructions' => '• ري بانتظام\n• تأكد من تصريف الماء\n• تجنب التعرض المباشر للشمس الحارقة',
            'description' => 'لم يتم التعرف على النبات. يرجى المحاولة بصورة أخرى.',
        ];
    }
}