// -----------------------------------------------------
// Generate random metrics to load test OTel collector.
//
// Author : Keegan Mullaney
// Company: New Relic
// Website: github.com/keegoid-nr/otel-load-test
// License: Apache 2.0
// -----------------------------------------------------

package main

import (
	"context"
	"log"
  "math/rand"
	"os"
	"os/signal"
	"syscall"
	"time"

	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetricgrpc"
  api "go.opentelemetry.io/otel/metric"
	"go.opentelemetry.io/otel/sdk/metric"
	"go.opentelemetry.io/otel/sdk/resource"
	semconv "go.opentelemetry.io/otel/semconv/v1.21.0"
)

const meterName = "github.com/keegoid-nr/otel-load-test"

func main() {
  log.Println("Application is starting...")

  ctx := context.Background()

  // Create a Meter Provider with custom aggregation selector
  res, err := resource.Merge(resource.Default(),
    resource.NewWithAttributes(semconv.SchemaURL,
      semconv.ServiceName("otel-load-test"),
      semconv.ServiceVersion("0.1.0"),
      semconv.ServiceInstanceID("go-app-1"),
    ),
  )
  if err != nil {
    log.Fatalf("failed to create resource: %v\n", err)
  }

  // Configure OTLP Exporter
  exporter, err := otlpmetricgrpc.New(ctx)
  if err != nil {
    log.Fatalf("failed to create exporter: %v\n", err)
  }

  // Create a periodic reader
  reader := metric.NewPeriodicReader(
    exporter,
    metric.WithInterval(5),
  )

  // Create a meter
  provider := metric.NewMeterProvider(
    metric.WithResource(res),
    metric.WithReader(reader),
  )

  meter := provider.Meter(meterName)

  // Start metric generation
  go generateMetrics(ctx, meter)

  // Handle interrupts
  c := make(chan os.Signal, 1)
  signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)

  <-c
  log.Println("SIGINT received. Gracefully stopping the application...")
}

func generateMetrics(ctx context.Context, meter api.Meter) {
  // request counter
  httpRequestsCounter, err := meter.Int64Counter("http_count", api.WithDescription("count of HTTP requests"))
  if err != nil {
		log.Fatalf("failed to create httpRequestsCounter: %v\n", err)
	}

  // error rate gauge
  errorRateGauge, err := meter.Float64ObservableGauge("error_rate", api.WithDescription("rate of status_code errors"))
  if err != nil {
		log.Fatalf("failed to create errorRateGauge: %v\n", err)
	}

  // methods and status codes
  httpMethods := []string{"GET", "POST", "PUT", "DELETE"}
  statusCodes := []int{200, 201, 202, 204, 400, 401, 403, 404, 500, 502, 503, 504}

  // metric generation loop
  for {
    statusCodeWeights := generateStatusCodeWeights(statusCodes)
    // log.Printf("Status Code Weights: %0.6f\n", statusCodeWeights)

    method := httpMethods[rand.Intn(len(httpMethods))]
    statusCode := weightedChoice(statusCodes, statusCodeWeights)
    // log.Printf("Chosen Status Code: %d\n", statusCode)

    value := rand.Int63n(1000) + 1

    labels := api.WithAttributes(
      attribute.Key("http.method").String(method),
      attribute.Key("http.status_code").Int(statusCode),
      attribute.Key("http.server.duration").Int64(value),
    )

    httpRequestsCounter.Add(ctx, 1, labels)

    if statusCode > 204 {
      chosenWeight := statusCodeWeights[findIndex(statusCodes, statusCode)]
      log.Printf("Status Code Weights: %0.6f\n", statusCodeWeights)
      log.Printf("Chosen Status Code: %d\n", statusCode)
      log.Printf("Chosen Weight: %0.6f\n", chosenWeight)
      _, err = meter.RegisterCallback(func(_ context.Context, o api.Observer) error {
        o.ObserveFloat64(errorRateGauge, chosenWeight, labels)
        return nil
      }, errorRateGauge)
      if err != nil {
        log.Fatalf("failed to observe chosenWeight: %v\n", err)
      }
    }

    sleepDuration := time.Duration(rand.Intn(100-10)+10) * time.Millisecond
    time.Sleep(sleepDuration)
  }
}

func generateStatusCodeWeights(statusCodes []int) []float64 {
    firstStatusCodeWeight := 0.95
    remainingProbability := 1.0 - firstStatusCodeWeight
    var otherStatusCodeWeights []float64
    totalWeight := 0.0

    for i := 0; i < len(statusCodes)-1; i++ {
        weight := rand.Float64()
        otherStatusCodeWeights = append(otherStatusCodeWeights, weight)
        totalWeight += weight
    }

    // Normalize the other weights to ensure their sum is equal to the remaining probability
    for i := 0; i < len(statusCodes)-1; i++ {
        otherStatusCodeWeights[i] = otherStatusCodeWeights[i] / totalWeight * remainingProbability
    }

    return append([]float64{firstStatusCodeWeight}, otherStatusCodeWeights...)
}

func weightedChoice(choices []int, weights []float64) int {
  sum := 0.0
  for _, weight := range weights {
    sum += weight
  }

  r := rand.Float64() * sum
  for i, weight := range weights {
    r -= weight
    if r <= 0 {
      return choices[i]
    }
  }

  // Fallback in case of rounding issues, return last choice
  return choices[len(choices)-1]
}

func findIndex(arr []int, target int) int {
    for i, v := range arr {
        if v == target {
            return i
        }
    }
    return -1
}
