import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["start", "end", "price", "warning"]
  static values = {
    price: Number,
    occupied: Array
  }

  connect() {
    this.update()
  }

  update() {
    const start = this.parseDate(this.startTarget?.value)
    const end = this.parseDate(this.endTarget?.value)

    if (!start || !end || end <= start) {
      this.priceTarget.textContent = "Стоимость: 0 ₽"
      this.hideWarning()
      return
    }

    const hours = (end - start) / 3600000
    const total = Math.round(this.priceValue * hours * 100) / 100
    this.priceTarget.textContent = `Стоимость: ${total} ₽`

    if (this.overlapsOccupied(start, end)) {
      this.warningTarget.textContent = "Выбранное время пересекается с занятым слотом"
      this.warningTarget.hidden = false
    } else {
      this.hideWarning()
    }
  }

  parseDate(value) {
    if (!value) return null
    return new Date(value)
  }

  overlapsOccupied(start, end) {
    return this.occupiedValue.some((slot) => {
      const slotStart = new Date(slot.start)
      const slotEnd = new Date(slot.end)
      return start < slotEnd && end > slotStart
    })
  }

  hideWarning() {
    if (this.hasWarningTarget) {
      this.warningTarget.hidden = true
      this.warningTarget.textContent = ""
    }
  }
}