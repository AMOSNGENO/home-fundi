<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;

class BaseController extends Controller
{
    /**
     * Success Response
     */
    public function sendResponse($result, $message = null, $statusCode = Response::HTTP_OK): JsonResponse
    {
        $response = [
            'success' => true,
            'data' => $result,
        ];

        if ($message) {
            $response['message'] = $message;
        }

        return response()->json($response, $statusCode);
    }

    /**
     * Error Response
     */
    public function sendError($error, $errorMessages = [], $code = Response::HTTP_BAD_REQUEST): JsonResponse
    {
        $response = [
            'success' => false,
            'message' => $error,
        ];

        if (!empty($errorMessages)) {
            $response['data'] = $errorMessages;
        }

        return response()->json($response, $code);
    }

    /**
     * Validation Error Response
     */
    public function sendValidationError($errors): JsonResponse
    {
        return $this->sendError(
            'Validation Error',
            $errors,
            Response::HTTP_UNPROCESSABLE_ENTITY
        );
    }

    /**
     * Unauthorized Response
     */
    public function sendUnauthorized(): JsonResponse
    {
        return $this->sendError(
            'Unauthorized',
            [],
            Response::HTTP_UNAUTHORIZED
        );
    }

    /**
     * Not Found Response
     */
    public function sendNotFound($message = 'Resource not found'): JsonResponse
    {
        return $this->sendError(
            $message,
            [],
            Response::HTTP_NOT_FOUND
        );
    }

    /**
     * Server Error Response
     */
    public function sendServerError($message = 'Internal Server Error'): JsonResponse
    {
        return $this->sendError(
            $message,
            [],
            Response::HTTP_INTERNAL_SERVER_ERROR
        );
    }
}
