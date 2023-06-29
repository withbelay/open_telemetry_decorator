defmodule OtelHelper do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      require OpenTelemetry, as: OpenTelemetry
      require OpenTelemetry.Tracer, as: Tracer
      require OpenTelemetry.Span, as: Span

      require Record
      @fields Record.extract(:span, from_lib: "opentelemetry/include/otel_span.hrl")
      # Allows pattern matching on spans via
      Record.defrecordp(:span, @fields)
      @fields Record.extract(:link, from_lib: "opentelemetry/include/otel_span.hrl")
      Record.defrecordp(:link, @fields)
      @fields Record.extract(:span_ctx, from_lib: "opentelemetry_api/include/opentelemetry.hrl")
      Record.defrecordp(:span_ctx, @fields)

      def otel_pid_reporter(_) do
        Application.put_env(:opentelemetry, :processors, [
          {
            :otel_batch_processor,
            %{scheduled_delay_ms: 1, exporter: {:otel_exporter_pid, self()}}
          }
        ])

        Application.stop(:opentelemetry)
        {:ok, _} = Application.ensure_all_started(:opentelemetry)

        # Cannot use `on_exit` to stop opentelemetry as `on_exit` occurs in a process different than the test.
        # This results in a race condition where the opentelemetry process started by this setup routine is
        # killed by the `on_exit` routine from some prior test.  Instead, since each test is synchronous within the
        # suite, we'll just restart opentelemetry in each test setup.
        # on_exit(fn ->
        #   Application.stop(:opentelemetry)
        # end)

        :ok
      end

      def get_span_attributes(attributes) do
        # https://github.com/open-telemetry/opentelemetry-erlang/blob/main/apps/opentelemetry/src/otel_attributes.erl#L26-L31
        # e.g. {:attributes, 128, :infinity, 0, %{count: 2}}
        {:attributes, _, :infinity, _, attr} = attributes
        attr
      end

      def get_span_events(events) do
        # https://github.com/open-telemetry/opentelemetry-erlang/blob/main/apps/opentelemetry/src/otel_attributes.erl#L26-L31
        # e.g. {:events, 128, 128, :infinity, 0, []}
        {:events, _, _, :infinity, _, event_list} = events
        event_list
      end

      def get_span_links(links) do
        # https://github.com/open-telemetry/opentelemetry-erlang/blob/main/apps/opentelemetry/src/otel_links.erl#L27-L33
        # e.g. {:links, 128, 128, :infinity, 0, []}
        {:links, _, _, :infinity, _, span_links} = links
        span_links
      end
    end
  end
end
