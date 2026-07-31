tidy.occurrence <- function(data) {
  data |>
    dplyr::mutate(
      id = clean_id(id),
      name = dplyr::if_else(
        is.na(vernacularName),
        stringr::str_to_sentence(scientificName),
        paste0(
          stringr::str_to_sentence(scientificName), " (", stringr::str_to_title(vernacularName), ")"
        )
      ),
      kingdom = stringr::str_to_title(kingdom),
      family = family |> stringr::word(-1, sep = "_") |> stringr::str_to_title(),
      individual_count = as.integer(individualCount),
      life_stage = stringr::str_to_title(lifeStage),
      sex = stringr::str_to_title(sex),
      lat = as.double(latitudeDecimal),
      long = as.double(longitudeDecimal),
      continent = stringr::str_to_title(continent),
      country = stringr::str_to_title(country),
      locality = stringr::str_to_title(locality),
      event_date = as.Date(eventDate),
      event_time = eventTime,
      .keep = "none"
     )
}

tidy.multimedia <- function(data) {
  data |>
    dplyr::mutate(
      id = clean_id(CoreId),
      image_url = as.character(accessURI),
      creator = stringr::str_to_title(creator),
      rights_holder = as.character(rightsHolder),
      license = as.character(license),
      .keep = "none"
    )
}

tidy.timeline <- function(data, period = c("year", "month", "hour")) {
  period <- match.arg(period)

  df <-
    data |>
    dplyr::mutate(
      individual_count,
      year = lubridate::floor_date(event_date, "year"),
      month = lubridate::month(event_date) |> as.integer(),
      hour = hms::as_hms(event_time) |> lubridate::hour() |> as.integer(),
      .keep = "none"
    ) |>
    dplyr::summarise(Observations = sum(individual_count, na.rm = TRUE), .by = period) |>
    dplyr::arrange(!!dplyr::sym(period))

  complete_vector <- switch(
    period,
    year = df |> dplyr::pull(1) |> (\(x) seq.Date(x[[1]], x[[length(x)]], "year"))(),
    month = seq.int(1, 12, 1),
    hour = seq.int(1, 23, 1)
  )

  df |>
    tidyr::drop_na() |>
    tidyr::complete(!!dplyr::sym(period) := complete_vector, fill = list(Observations = 0L))
}

tidy.ranking <- function(data, .by, n = 4) {
  data |>
    dplyr::summarise(Observations = sum(individual_count, na.rm = FALSE), .by = .by) |>
    dplyr::arrange(Observations) |>
    dplyr::mutate(
      !!dplyr::sym(.by) := dplyr::if_else(dplyr::row_number() > n, "Others", !!dplyr::sym(.by))
      ) |>
    dplyr::summarise(Observations = sum(Observations), .by = .by) |>
    dplyr::rename_with(\(name) stringr::str_replace(name, "_", " ")) |>
    dplyr::rename_with(stringr::str_to_sentence)
}

tidy.valuebox <- function(data, .by) {
  data |>
    dplyr::summarise(Observations = sum(individual_count, na.rm = FALSE), .by = .by) |>
    dplyr::arrange(Observations) |>
    dplyr::rename_with(stringr::str_to_sentence)
}

tidy.coords_sf <- function(data) {
  # Made with the help of Claude Sonnet 4.5
  data |>
    sf::st_as_sf(coords = c("long", "lat"), crs = 4326) |>
    sf::st_jitter(factor = 0.0001)
}

tidy.map_popup <- function(data) {
  # Made with the help of Claude Sonnet 4.5
  data |>
    dplyr::mutate(
      # Create unique ID for each row BEFORE glue
      popup_id = dplyr::row_number(),
      images_processed = dplyr::case_when(
        is.na(images) | trimws(as.character(images)) == "" ~ "dir/img/gbif-mark-blue-logo.png",
        .default = as.character(images)
      )
    ) |>
    dplyr::rowwise() |>
    dplyr::mutate(
      # Split images into list
      image_list = list(trimws(unlist(strsplit(images_processed, ",")))),
      # Generate image HTML
      images_html = paste(
        sapply(seq_along(image_list), function(i) {
          sprintf(
            '<img src="%s" style="width: 100%%; height: 100%%; object-fit: cover; position: absolute; top: 0; left: 0; opacity: %s; transition: opacity 0.5s ease-in-out;">',
            image_list[i],
            if(i == 1) "1" else "0"
          )
        }),
        collapse = ""
      )
    ) |>
    dplyr::mutate(popup_content = glue::glue('
    <div style="font-family: \'Open Sans\', sans-serif; max-width: 600px; padding: 12px; background-color: #f8f9fa; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.15);">
      <h3 style="color: #4C9C2E; margin-top: 0; font-size: 18px; font-weight: bold; margin-bottom: 12px;">{name}</h3>
      <div style="display: flex; gap: 15px;">
        <div style="flex: 1; color: #495057; line-height: 1.6;">
          <p style="margin: 0;">
            <strong>Date:</strong> {event_date}<br>
            <strong>Time:</strong> {event_time}<br>
            <strong>Observations:</strong> {individual_count}<br>
            <strong>Life stage:</strong> {life_stage}<br>
            <strong>Sex:</strong> {sex}<br>
            <strong>Locality:</strong> {locality}
          </p>
        </div>
        <div style="flex: 0 0 250px; position: relative;">
          <div class="carousel-{popup_id}" style="width: 250px; height: 200px; position: relative; overflow: hidden; border-radius: 6px; background: #e9ecef;">
            {images_html}
          </div>
          <button onclick="changeSlide_{popup_id}(-1)" style="position: absolute; left: 5px; top: 50%; transform: translateY(-50%); background: rgba(255,255,255,0.8); border: none; border-radius: 50%; width: 30px; height: 30px; cursor: pointer; font-size: 16px; display: flex; align-items: center; justify-content: center; z-index: 10;">&lt;</button>
          <button onclick="changeSlide_{popup_id}(1)" style="position: absolute; right: 5px; top: 50%; transform: translateY(-50%); background: rgba(255,255,255,0.8); border: none; border-radius: 50%; width: 30px; height: 30px; cursor: pointer; font-size: 16px; display: flex; align-items: center; justify-content: center; z-index: 10;">&gt;</button>
          <div style="position: absolute; bottom: 10px; left: 50%; transform: translateX(-50%); display: flex; gap: 5px; z-index: 10;" class="dots-{popup_id}">
          </div>
        </div>
      </div>
      <script>
        (function() {{
          let currentSlide_{popup_id} = 0;
          const carousel = document.querySelector(\'.carousel-{popup_id}\');
          if (!carousel) return;

          const slides = carousel.querySelectorAll(\'img\');
          const dotsContainer = document.querySelector(\'.dots-{popup_id}\');

          if (slides.length === 0) return;

          // Create dots
          slides.forEach((_, index) => {{
            const dot = document.createElement(\'span\');
            dot.style.cssText = \'width: 8px; height: 8px; border-radius: 50%; background: rgba(255,255,255,0.5); cursor: pointer; transition: background 0.3s;\';
            dot.onclick = () => showSlide_{popup_id}(index);
            dotsContainer.appendChild(dot);
          }});

          const dots = dotsContainer.querySelectorAll(\'span\');

          function showSlide_{popup_id}(n) {{
            currentSlide_{popup_id} = (n + slides.length) % slides.length;
            slides.forEach((slide, index) => {{
              slide.style.opacity = index === currentSlide_{popup_id} ? \'1\' : \'0\';
            }});
            dots.forEach((dot, index) => {{
              dot.style.background = index === currentSlide_{popup_id} ? \'rgba(255,255,255,1)\' : \'rgba(255,255,255,0.5)\';
            }});
          }}

          window.changeSlide_{popup_id} = function(direction) {{
            showSlide_{popup_id}(currentSlide_{popup_id} + direction);
          }};

          showSlide_{popup_id}(0);
        }})();
      </script>
    </div>
  ')) |>
    dplyr::ungroup() |>
    dplyr::select(-popup_id, -images_processed, -image_list, -images_html)
}
