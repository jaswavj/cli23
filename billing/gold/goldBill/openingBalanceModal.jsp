<!-- Opening Balance Modal -->
<div class="modal fade" id="openingBalanceModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="openingBalanceModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header" style="background: linear-gradient(135deg, #1a1a2e 0%, #0f3460 100%); color: white;">
                <h5 class="modal-title" id="openingBalanceModalLabel">
                    <i class="fa-solid fa-wallet me-2"></i>Enter Opening Balance
                </h5>
            </div>
            <div class="modal-body">
                <div class="alert alert-info">
                    <i class="fa-solid fa-info-circle me-2"></i>
                    Please enter the opening balance for today (<span id="openingBalanceDate"></span>)
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Opening Balance Amount</label>
                    <input type="number" step="0.01" id="openingBalanceAmount" class="form-control" placeholder="0.00" required>
                </div>
                <div id="openingBalanceError" class="alert alert-danger d-none"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" id="btnCancelOpeningBalance">Cancel</button>
                <button type="button" class="btn btn-primary" id="btnSaveOpeningBalance">
                    <i class="fa-solid fa-save me-1"></i>Save
                </button>
            </div>
        </div>
    </div>
</div>

<script>
let openingBalanceModal;
let openingBalanceRequired = false;
let openingBalanceCancelled = false;

function initOpeningBalanceModal() {
    openingBalanceModal = new bootstrap.Modal(document.getElementById('openingBalanceModal'));
    
    // Set today's date
    const today = new Date().toLocaleDateString('en-GB');
    document.getElementById('openingBalanceDate').textContent = today;
    
    // Cancel button handler
    document.getElementById('btnCancelOpeningBalance').addEventListener('click', function() {
        openingBalanceCancelled = true;
        openingBalanceModal.hide();
    });
    
    // Save button handler
    document.getElementById('btnSaveOpeningBalance').addEventListener('click', function() {
        saveOpeningBalance();
    });
    
    // Enter key handler
    document.getElementById('openingBalanceAmount').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            saveOpeningBalance();
        }
    });
}

function checkOpeningBalance(onCancelled) {
    fetch('<%= request.getContextPath() %>/gold/goldBill/checkOpeningBalance.jsp')
        .then(response => response.json())
        .then(data => {
            if (data.status === 'ok' && !data.hasOpeningEntry) {
                openingBalanceRequired = true;
                showOpeningBalanceModal(onCancelled);
            }
        })
        .catch(error => {
            console.error('Error checking opening balance:', error);
        });
}

function showOpeningBalanceModal(onCancelled) {
    if (!openingBalanceModal) {
        initOpeningBalanceModal();
    }
    
    // Store the callback for when cancelled
    if (onCancelled) {
        document.getElementById('btnCancelOpeningBalance').onclick = function() {
            openingBalanceCancelled = true;
            openingBalanceModal.hide();
            onCancelled();
        };
    }
    
    document.getElementById('openingBalanceAmount').value = '';
    document.getElementById('openingBalanceError').classList.add('d-none');
    openingBalanceModal.show();
    
    // Focus on input after modal is shown
    setTimeout(() => {
        document.getElementById('openingBalanceAmount').focus();
    }, 500);
}

function saveOpeningBalance() {
    const amount = document.getElementById('openingBalanceAmount').value;
    const errorDiv = document.getElementById('openingBalanceError');
    
    if (!amount || parseFloat(amount) < 0) {
        errorDiv.textContent = 'Please enter a valid amount';
        errorDiv.classList.remove('d-none');
        return;
    }
    
    const btn = document.getElementById('btnSaveOpeningBalance');
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Saving...';
    
    fetch('<%= request.getContextPath() %>/gold/goldBill/saveOpeningBalance.jsp?balance=' + amount)
        .then(response => response.json())
        .then(data => {
            if (data.status === 'ok') {
                openingBalanceRequired = false;
                openingBalanceCancelled = false;
                openingBalanceModal.hide();
                
                // Show success message
                Swal.fire({
                    icon: 'success',
                    title: 'Success',
                    text: 'Opening balance saved successfully',
                    timer: 2000,
                    showConfirmButton: false
                });
            } else {
                errorDiv.textContent = data.message || 'Failed to save opening balance';
                errorDiv.classList.remove('d-none');
            }
        })
        .catch(error => {
            errorDiv.textContent = 'Error: ' + error.message;
            errorDiv.classList.remove('d-none');
        })
        .finally(() => {
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-save me-1"></i>Save';
        });
}

// Initialize on page load
if (typeof window !== 'undefined') {
    initOpeningBalanceModal();
}
</script>
