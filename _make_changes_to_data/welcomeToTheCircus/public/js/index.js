// ------------------------------------------------------------------
//  Get the all the clowns and load them into a single block.
async function getClowns() {
   try {
    const response = await fetch(
      '/clowns/',
      {
        method: 'GET',
      },
    );

    if (!response.ok) {
      throw new Error(`Error! status: ${response.status}`);
    }

    const data = await response.json();

    return data;
  } catch (error) {
    console.log(error);
  }
}

getClowns().then(data => {
  console.log(data);
  const preElement = document.getElementById('all-clowns');
  preElement.innerHTML = JSON.stringify(data, null, 2);
});

// ------------------------------------------------------------------
//  Get a single clown and load it into different parts of the DOM
//  by id. 

function getElement(id) {
  return document.getElementById(id);
}

async function getClown(id) {
  let callRoute =`/clowns/${id}`
  console.log(callRoute)
  try {
    const response = await fetch(
      callRoute,
      {
        method: 'GET',
      },
    );

    if (!response.ok) {
      throw new Error(`Error! status: ${response.status}`);
    }

    const data = await response.json();

    return data;
  } catch (error) {
    console.log(error);
  }
}

getClown(4).then(data => {
  console.log(data);
  getElement('id').innerHTML =  'ID: ' + data.id;
  getElement('name').innerHTML = 'Name: ' + data.name;
  getElement('spareNoses').innerHTML = 'Nose Count: ' + data.spareNoses;
});