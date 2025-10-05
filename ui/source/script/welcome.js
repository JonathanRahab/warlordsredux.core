document.addEventListener('mousedown', function (e) {
    const target = e.target;
    if (target.tagName === 'A' && target.closest('.left-panel')) {
        e.preventDefault();
        const href = target.getAttribute('href');
        const decodedHref = decodeURIComponent(href.replace(/[()\/]/g, '').replace(/\s+/g, '-').toLowerCase());

        const subheading = document.querySelector(decodedHref);
        console.log(subheading);
        if (subheading && subheading.tagName !== 'DIV') {
            const parentPanel = subheading.closest('.right-panel');
            if (parentPanel) {
                document.querySelectorAll('.right-panel').forEach(p => p.style.display = 'none');
                parentPanel.style.display = 'inline-block';

                subheading.scrollIntoView({ behavior: 'smooth', block: 'start' });

                const paragraphs = [];
                let nextElement = subheading.nextElementSibling;
                while (nextElement && nextElement.tagName === 'P') {
                    paragraphs.push(nextElement);
                    nextElement = nextElement.nextElementSibling;
                }

                const elementsToHighlight = [subheading, ...paragraphs];
                elementsToHighlight.forEach(el => {
                    el.style.backgroundColor = '#444';
                });

                setTimeout(() => {
                    elementsToHighlight.forEach(el => {
                        el.style.backgroundColor = '';
                    });
                }, 1500);
            }
        } else {
            const panel = document.querySelector('.right-panel' + href);
            if (panel) {
                document.querySelectorAll('.right-panel').forEach(p => p.style.display = 'none');
                panel.style.display = 'inline-block';
            }
        }
    }
});

function generateLeftNav() {
    const leftPanel = document.querySelector('.left-panel ul');
    const rightPanels = document.querySelectorAll('.right-panel');

    const categories = new Set();

    rightPanels.forEach(panel => {
        const id = panel.id;
        const title = panel.querySelector('h2')?.textContent;
        const category = Array.from(panel.classList).find(cls => cls.startsWith('category-'));

        if (category && !categories.has(category)) {
            const categoryName = category.replace('category-', '').replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
            const categoryItem = document.createElement('li');
            categoryItem.classList.add('category-item');
            categoryItem.textContent = categoryName;
            leftPanel.appendChild(categoryItem);
            categories.add(category);
        }

        if (id && title) {
            const listItem = document.createElement('li');
            const link = document.createElement('a');
            link.href = `#${id}`;
            link.textContent = title;
            listItem.appendChild(link);
            leftPanel.appendChild(listItem);

            const subheadings = panel.querySelectorAll('h3');
            subheadings.forEach(subheading => {
                const subId = `${id}-${subheading.textContent.replace(/[()\/]/g, '').replace(/\s+/g, '-').toLowerCase()}`;
                subheading.id = subId;

                const subListItem = document.createElement('li');
                subListItem.style.marginLeft = '20px';
                const subLink = document.createElement('a');
                subLink.href = `#${subId}`;
                subLink.textContent = subheading.textContent;
                subListItem.appendChild(subLink);
                leftPanel.appendChild(subListItem);
            });
        }
    });
}

// Call the function to populate the left navigation panel
document.addEventListener('DOMContentLoaded', generateLeftNav);