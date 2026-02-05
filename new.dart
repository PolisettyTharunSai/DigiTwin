

  // ... (Rest of state remains the same)

  Widget _buildCropField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(
                Icons.shopping_basket_outlined, color: primaryPurple, size: 16),
            const SizedBox(width: 10),
            Text(
              _t('potato'),
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

// ... (Rest of class implementation)
}