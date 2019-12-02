
// --------------------------------------------------------------------------------------------------------------
// @brief
// This iz where de fun beginz
document.addEventListener('DOMContentLoaded', () => 
{
    console.log('> Document loaded');

    keepFooterAtBottom();
    setupLeaflet();
    document.addEventListener('scroll', keepFooterAtBottom);
});


// --------------------------------------------------------------------------------------------------------------
// @brief
//  The footer is always at the bottom of the page if there isn't enough content on the page to naturally keep it
function keepFooterAtBottom () {
    const footer = document.getElementsByTagName('footer')[0];
}


// --------------------------------------------------------------------------------------------------------------
// @brief
//  Initializes and sets up the Leaflet map
// @source
//   https://github.com/ewoken/Leaflet.MovingMarker
function setupLeaflet () {
    var mymap = L.map('leafletMap').setView(
        [45.74846, 4.84671], // Lyon's geographical coordinates
        11 // zoom level
    );

    const accessToken = 'pk.eyJ1IjoiY291Y291aWxsZSIsImEiOiJjazNvZzhmdnUxbGFkM2tvN2FyZ2t4NjZiIn0.0RGUwtF2X-i72qCEeb_G0w';
    L.tileLayer(
        `https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=${accessToken}`, 
        {
            attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
            maxZoom: 18,
            id: 'mapbox/streets-v11',
            accessToken
        }
    ).addTo(mymap);

    var circle = L.circle([45.74846, 4.84671], {
        color: 'red',
        fillColor: '#f03',
        fillOpacity: 0.5,
        radius: 500
    }).addTo(mymap);

    const start = [4.84671,45.54846];
    const end = [4.84671,45.94846];
    fetchAndDisplayRoute(start, end, mymap);
}


// --------------------------------------------------------------------------------------------------------------
// @brief
//  Fetches the route computed by the OSRM online and free engine and displays it on the leaflet map 'mymap'
// @note
//  The 'from' and 'to' variables are arrays containing latitude and longitude data
function fetchAndDisplayRoute (from, to, mymap) 
{
    fetch(`http://router.project-osrm.org/route/v1/driving/${from[0]},${from[1]};${to[0]},${to[1]}?overview=full`)
    .then(r => r.json()).then(data => {
        try {
            data.routes.map(m => {
                let decodedPolyline = L.polyline(
                    polyline.decode(m.geometry), {
                    color: 'red',
                    weight: 3,
                    opacity: 1
                });
                decodedPolyline.addTo(mymap);
                addMovingMarker(decodedPolyline['_latlngs'], 6000, mymap);
            });
        } catch(e) {
            console.error('Too many calls to the OSRM API. Try again later ('+e+')')
        }
    });
}


// --------------------------------------------------------------------------------------------------------------
// @brief
//  Adds a marker in the Leaflet map 'mymap' form the coordinates 'start' to 'end' and a duration of 'duration'
// expressed in milliseconds
function addMovingMarker (steps, duration, mymap) 
{
    // drawing the line the moving marker will follow
    let coordinateArray = [...steps];
    let myPolyline = L.polyline(coordinateArray);
    myPolyline.addTo(mymap);

    // adding start & end markers
    L.marker(coordinateArray[0]).addTo(mymap);
    L.marker(coordinateArray[coordinateArray.length - 1]).addTo(mymap);

    // here is the moving marker (6 seconds animation)
    let myMovingMarker = L.Marker.movingMarker(coordinateArray, duration, { autostart: false });
    mymap.addLayer(myMovingMarker);
    myMovingMarker.start();
}


// --------------------------------------------------------------------------------------------------------------
// @brief
//  Fetches all the incendie data from the PostgreSQL database and displays them inside the Leaflet map
async function fetchAndDisplayIncendie () {
    fetch('http://127.0.0.1:5000/data').then(r => r.json()).then(data => 
    {
        updateIncendieData(data)
    })
    .catch(e => { console.error(e) })
}


// --------------------------------------------------------------------------------------------------------------
// @brief
//  In the Leaflet map, updates all the displayed data with the new 'newDataset'
function updateIncendieData (newDataset) {
    for (let data of newDataset) {
        console.log(data)
    }
}