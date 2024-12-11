let likeCount = 0;
let shareCount = 0;

// Get the buttons
const likeButton = document.querySelector(".like-button");
const shareButton = document.querySelector(".share-button");

// Event listener for the Like button
likeButton.addEventListener("click", function () {
  if (likeButton.classList.contains("liked")) {
    // If already liked, remove the like and decrement the count
    likeButton.classList.remove("liked");
    likeCount--;
  } else {
    // If not liked, add the like and increment the count
    likeButton.classList.add("liked");
    likeCount++;
  }
  console.log("Like Count:", likeCount + shareCount); // Output the current like count
});

// Event listener for the Share button
shareButton.addEventListener("click", function () {
  if (shareButton.classList.contains("shared")) {
    // If already shared, remove the share and decrement the count
    shareButton.classList.remove("shared");
    shareCount--;
  } else {
    // If not shared, add the share and increment the count
    shareButton.classList.add("shared");
    shareCount++;
  }
  console.log("Share Count:", likeCount + shareCount); // Output the current share count
});

