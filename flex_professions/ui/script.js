var canEscape = false;
let selectedJobData = null;

window.addEventListener('message', function(event) {
    const data = event.data;
    canEscape = data.canEscape || false;
    try {
        switch(data.action) {
            case "open":
                $( "#container" ).fadeIn( "slow", function() {
                    const container = document.querySelector('#container');
                    if (!container) return;
                    container.style.display = 'block';

                    const title = document.querySelector('#title');
                    if (title && data.title) {
                        title.innerText = data.title;
                    }
    
                    const desc = document.querySelector('#desc');
                    if (desc && data.desc) {
                        desc.innerText = data.desc;
                    }
    
                    const jobs = document.querySelector('#jobs');
                    if (jobs && data.jobs) {
                        data.jobs.forEach((item, index) => {
                            if (!item) return;
                            const itemsContainer = document.querySelector('#jobs');
    
                            const itemElement = document.createElement('div');
                            const html = `
                                <div class="profession" style="border-top:.3vw solid ${item.rgb || 'rgb(0, 0, 0)'};">
                                    <h2>${item.label || 'PROFESSION'}</h2>
                                    <p>${item.desc || 'DESCRIPTION'}</p>
                                    <div class="btn" 
                                        interview="${item.application ? 'true' : 'false'}" 
                                        data-item='${JSON.stringify(item)}'>
                                        ${item.application ? 'APPLY' : 'CHOOSE'}
                                    </div>
                                </div>
                            `;
                            itemElement.innerHTML = html;
                            $(itemElement).hide();
                            itemsContainer.appendChild(itemElement);
                            $(itemElement).delay(index * 250).fadeIn("slow");
                        });
                    }

                    $(document).on('click', '.btn[interview="false"]', function() {
                        const interview = $(this).attr('interview') === 'true';
                        const jobData = JSON.parse($(this).attr('data-item') || '{}'); // parse JSON
                        if(!interview){
                            $.post(`https://${GetParentResourceName()}/select`, JSON.stringify({jobData: jobData}));
                            canEscape = true;
                            closeMenu();
                            return;
                        }
                    });

                    $(document).on('click', '.btn[interview="true"]', function() {
                        $('#applicationOverlay').fadeIn(400);
                        selectedJobData = JSON.parse($(this).attr('data-item') || '{}');
                    });

                    $(document).on('click', '.btn.cancel', function() {
                        $('#applicationOverlay').fadeOut(400);
                    });

                    $(document).on('click', '.btn.submit', function() {
                        if (!selectedJobData) {
                            console.error('No job selected for application');
                            return;
                        }

                        const formData = {
                            name: $('#name').val(),
                            birth: $('#birth').val(),
                            why: $('#why').val(),
                            fit: $('#fit').val(),
                            jobData: selectedJobData
                        };

                        $.post(`https://${GetParentResourceName()}/apply`, JSON.stringify(formData));

                        $.post(`https://${GetParentResourceName()}/select`, JSON.stringify({ jobData: selectedJobData }));

                        $('#applicationOverlay').fadeOut(400);

                        setTimeout(() => {
                            canEscape = true;
                            closeMenu();
                        }, 300);
                    });
                });
                break;
                
            case "close":
                closeMenu()
                break;
                
        }
    } catch (error) {
        console.error('Could not load professions:', error);
    }
});

function closeMenu() {
    if (!canEscape) return;
    
    $.post(`https://${GetParentResourceName()}/close`);
    $( "#container" ).delay(200).fadeOut(3300, function() {
        const container = document.querySelector('#container');
        if (!container) return;
        container.style.display = 'none';
        const jobs = document.querySelector('#jobs');
        if (jobs) jobs.innerHTML = '';
    });
}

// Close menu on Escape key
document.onkeyup = function(event) {
    if (event.key === "Escape") {
        closeMenu();
    }
};