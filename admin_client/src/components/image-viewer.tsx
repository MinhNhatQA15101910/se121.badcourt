export function createImageViewerHTML(title: string, imageUrl: string, index: number, images: string[]) {
    // Create a JSON string of all images in this section
    const imagesJson = JSON.stringify(images)
  
    // Create HTML content for the new window with image viewer functionality
    return `
      <!DOCTYPE html>
      <html>
        <head>
          <title>Image Viewer - ${title}</title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body {
              margin: 0;
              padding: 0;
              display: flex;
              flex-direction: column;
              height: 100vh;
              background-color: #1a1a1a;
              color: white;
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            }
            .toolbar {
              display: flex;
              justify-content: space-between;
              padding: 12px;
              background-color: #2a2a2a;
            }
            .toolbar-left {
              display: flex;
              align-items: center;
            }
            .toolbar-right {
              display: flex;
              gap: 8px;
            }
            .toolbar button {
              background-color: #444;
              border: none;
              color: white;
              padding: 8px 12px;
              border-radius: 4px;
              cursor: pointer;
              display: flex;
              align-items: center;
              gap: 4px;
            }
            .toolbar button:hover {
              background-color: #555;
            }
            .toolbar button:disabled {
              opacity: 0.5;
              cursor: not-allowed;
            }
            .image-container {
              flex: 1;
              display: flex;
              align-items: center;
              justify-content: center;
              overflow: hidden;
              position: relative;
            }
            img {
              max-width: 100%;
              max-height: 100%;
              object-fit: contain;
              transition: transform 0.3s ease;
            }
            .icon {
              width: 16px;
              height: 16px;
            }
            .navigation-buttons {
              position: absolute;
              top: 0;
              left: 0;
              right: 0;
              bottom: 0;
              display: flex;
              justify-content: space-between;
              align-items: center;
              padding: 0 20px;
              pointer-events: none;
            }
            .nav-button {
              background-color: rgba(0, 0, 0, 0.5);
              border: none;
              color: white;
              width: 40px;
              height: 40px;
              border-radius: 50%;
              display: flex;
              align-items: center;
              justify-content: center;
              cursor: pointer;
              pointer-events: auto;
            }
            .nav-button:hover {
              background-color: rgba(0, 0, 0, 0.7);
            }
            .nav-button:disabled {
              opacity: 0.3;
              cursor: not-allowed;
            }
            .image-counter {
              color: #ccc;
              margin-left: 10px;
            }
          </style>
        </head>
        <body>
          <div class="toolbar">
            <div class="toolbar-left">
              <span class="image-counter">Image <span id="current-index">1</span> of <span id="total-images">1</span></span>
            </div>
            <div class="toolbar-right">
              <button id="zoom-in">
                <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <circle cx="11" cy="11" r="8"></circle>
                  <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                  <line x1="11" y1="8" x2="11" y2="14"></line>
                  <line x1="8" y1="11" x2="14" y2="11"></line>
                </svg>
                Zoom In
              </button>
              <button id="zoom-out">
                <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <circle cx="11" cy="11" r="8"></circle>
                  <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                  <line x1="8" y1="11" x2="14" y2="11"></line>
                </svg>
                Zoom Out
              </button>
              <button id="download">
                <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                  <polyline points="7 10 12 15 17 10"></polyline>
                  <line x1="12" y1="15" x2="12" y2="3"></line>
                </svg>
                Download
              </button>
            </div>
          </div>
          <div class="image-container">
            <img id="image" src="${imageUrl}" alt="Document Image">
            <div class="navigation-buttons">
              <button id="prev-button" class="nav-button">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <polyline points="15 18 9 12 15 6"></polyline>
                </svg>
              </button>
              <button id="next-button" class="nav-button">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <polyline points="9 18 15 12 9 6"></polyline>
                </svg>
              </button>
            </div>
          </div>
          
          <script>
            // Parse the images array from JSON
            const images = ${imagesJson};
            let currentIndex = ${index};
            let scale = 1;
            
            const image = document.getElementById('image');
            const zoomIn = document.getElementById('zoom-in');
            const zoomOut = document.getElementById('zoom-out');
            const download = document.getElementById('download');
            const prevButton = document.getElementById('prev-button');
            const nextButton = document.getElementById('next-button');
            const currentIndexEl = document.getElementById('current-index');
            const totalImagesEl = document.getElementById('total-images');
            
            // Update the image counter
            totalImagesEl.textContent = images.length;
            updateImageCounter();
            updateNavigationButtons();
            
            // Zoom functionality
            zoomIn.addEventListener('click', () => {
              scale += 0.2;
              image.style.transform = \`scale(\${scale})\`;
            });
            
            zoomOut.addEventListener('click', () => {
              if (scale > 0.4) {
                scale -= 0.2;
                image.style.transform = \`scale(\${scale})\`;
              }
            });
            
            // Download functionality
            download.addEventListener('click', () => {
              const a = document.createElement('a');
              a.href = image.src;
              a.download = 'document-image-' + (currentIndex + 1) + '.jpg';
              document.body.appendChild(a);
              a.click();
              document.body.removeChild(a);
            });
            
            // Navigation functionality
            prevButton.addEventListener('click', () => {
              if (currentIndex > 0) {
                currentIndex--;
                updateImage();
                updateImageCounter();
                updateNavigationButtons();
                // Reset zoom when changing images
                scale = 1;
                image.style.transform = '';
              }
            });
            
            nextButton.addEventListener('click', () => {
              if (currentIndex < images.length - 1) {
                currentIndex++;
                updateImage();
                updateImageCounter();
                updateNavigationButtons();
                // Reset zoom when changing images
                scale = 1;
                image.style.transform = '';
              }
            });
            
            // Keyboard navigation
            document.addEventListener('keydown', (e) => {
              if (e.key === 'ArrowLeft' && currentIndex > 0) {
                prevButton.click();
              } else if (e.key === 'ArrowRight' && currentIndex < images.length - 1) {
                nextButton.click();
              }
            });
            
            function updateImage() {
              image.src = images[currentIndex];
            }
            
            function updateImageCounter() {
              currentIndexEl.textContent = currentIndex + 1;
            }
            
            function updateNavigationButtons() {
              prevButton.disabled = currentIndex === 0;
              nextButton.disabled = currentIndex === images.length - 1;
            }
          </script>
        </body>
      </html>
    `
  }
  
  